/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------
*/

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/
--1------------------------------------------------------
select sp.PersonID
	,sp.FullName
from Application.People as sp
where sp.IsSalesperson = 1
and sp.PersonID not in (select SalespersonPersonID
								from Sales.Invoices
								where InvoiceDate = '2015-07-04')
--2-----------------------------------------------------
;with cte_SalesPerson as (
								select si.SalespersonPersonID
								from Sales.Invoices si
								where si.InvoiceDate = '2015-07-04')
select sp.PersonID
	,sp.FullName
from Application.People as sp
where sp.IsSalesperson = 1
and not exists (select si.SalespersonPersonID from cte_SalesPerson si where sp.PersonID = si.SalespersonPersonID)



/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/
---1----------------------------------
select StockItemID
	,StockItemName
	,UnitPrice
from Warehouse.StockItems
where UnitPrice = (select min(UnitPrice) from Warehouse.StockItems)

--2---------------------------------------------
select StockItemID
	,StockItemName
	,UnitPrice
from Warehouse.StockItems
where UnitPrice <= ALL (select UnitPrice from Warehouse.StockItems)


/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/
--1-------------------------------------------------
;with cte_max as (
	select top 5 CustomerID
	from Sales.CustomerTransactions
	order by TransactionAmount desc
)

select distinct c. CustomerID
	,CustomerName
from Sales.Customers as c 
inner join cte_max as m on m.CustomerID = c.CustomerID


--2-----------------------------------------------
select c.CustomerID
	,c.CustomerName
from Sales.Customers as c 
where c.CustomerID in (	select top 5 CustomerID
								from Sales.CustomerTransactions
								order by TransactionAmount desc)

--3----------------------------------------------------
--тут явно показывается, что один и тот же клиент попал дважды в список 5ти клиентов, которые перевели компании пять максимальных платежей 
--явный ограничений в условии не было, необходимо уточнять
select top 5  c.CustomerID
	,c.CustomerName
from Sales.Customers  as c
inner join Sales.CustomerTransactions as ct on c.CustomerID = ct.CustomerID
order by ct.TransactionAmount desc

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

;with cte_StockItem as (
	select top 3 StockItemID
	from Warehouse.StockItems
	group by StockItemID, UnitPrice
	order by UnitPrice desc
)

select distinct c.DeliveryCityID, ac.CityName, ap.FullName
from Sales.Customers as c 
inner join Application.Cities as ac on ac.CityID = c.DeliveryCityID
inner join Sales.Invoices as i on c.CustomerID = i.CustomerID
inner join Application.People as ap on ap.PersonID = i.PackedByPersonID
inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
inner join cte_StockItem as st on st.StockItemID = il.StockItemID

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

--Для накладных с суммой более 27000 выводятся данные по накладной, дате составления накладной, имя сотрудника из команды продаж, 
--совершившего продажу, суммы накладной, а так же суммы заказа, если для заказа указана дата сборки
;with cte_invoices as
(select il.InvoiceId, SUM(il.Quantity*il.UnitPrice) as SumInvoice
				from Sales.InvoiceLines as il
				group by InvoiceID
				having SUM(il.Quantity*il.UnitPrice) > 27000)

,cte_order_sum as (
	select ol.OrderID
		,sum(ol.PickedQuantity*ol.UnitPrice) as SumOrder
	from Sales.OrderLines ol
	group by ol.OrderID
)
,cte_orders as (
	select o.OrderId 
	from Sales.Orders as o
	where o.PickingCompletedWhen is not null
	and exists (select ol.OrderID from cte_order_sum as ol where o.OrderID = ol.OrderID)
	)
select i.InvoiceID
	,i.InvoiceDate
	,ap.FullName as SalesPersonName
	,il.SumInvoice as TotalSummByInvoice
	,os.SumOrder as TotalSummForPickedItems
from Sales.Invoices as i
inner join cte_invoices as il on il.InvoiceID = i.InvoiceID
inner join Application.People as ap on ap.PersonID = i.SalespersonPersonID
left join cte_order_sum as os  on os.OrderID = i.OrderID


