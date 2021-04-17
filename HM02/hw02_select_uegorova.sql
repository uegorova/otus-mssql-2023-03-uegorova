/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

Задания выполняются с использованием базы данных WideWorldImporters.
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------
*/

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select StockItemID, StockItemName
from Warehouse.StockItems
where StockItemName like '%urgent%' or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select s.SupplierID, s.SupplierName
from Purchasing.Suppliers as s
left join Purchasing.PurchaseOrders as o on o.SupplierID = s.SupplierID
where o.SupplierID is null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select distinct o.OrderID
	,convert(varchar, o.OrderDate, 104) as OrderDate
	,datename(month, o.OrderDate) as NameofMonth
	,datepart(q, o.OrderDate) as OrderQuarted
	,case when month(o.OrderDate) <=4 then 1
			when month(o.OrderDate) >8 then 3
			else 2
		end OrderThirdofYear
	,c.CustomerName
from Sales.Orders as o
inner join Sales.OrderLines as ol on ol.OrderID = o.OrderID
inner join Sales.Customers as c on c.CustomerID = o.CustomerID 
where (ol.UnitPrice > 100 or ol.Quantity > 20)
	and ol.PickingCompletedWhen is not null
order by datepart(q, o.OrderDate) 
	,OrderThirdofYear
	,o.OrderDate


--вариант запроса с постраничной выборкой, пропустив первую 1000 и отобразив следующие 100 записей
select distinct o.OrderID
	,convert(varchar, o.OrderDate, 104) as OrderDate
	,datename(month, o.OrderDate) as NameofMonth
	,datepart(q, o.OrderDate) as OrderQuarted
	,case when month(o.OrderDate) <=4 then 1
			when month(o.OrderDate) >8 then 3
			else 2
		end OrderThirdofYear
	,c.CustomerName
from Sales.Orders as o
inner join Sales.OrderLines as ol on ol.OrderID = o.OrderID
inner join Sales.Customers as c on c.CustomerID = o.CustomerID 
where ol.UnitPrice > 100
	and ol.Quantity > 20
	and ol.PickingCompletedWhen is not null
order by datepart(q, o.OrderDate) 
	,case when month(o.OrderDate) <=4 then 1
			when month(o.OrderDate) >8 then 3
			else 2
		end
	,convert(varchar, o.OrderDate, 104)
offset 1000 rows fetch next 100 rows only


/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select dm.DeliveryMethodName
	,ExpectedDeliveryDate
	,s.SupplierName
	,p.FullName as ContactPerson
from Purchasing.PurchaseOrders as po
inner join Application.DeliveryMethods as dm on dm.DeliveryMethodID = po.DeliveryMethodID
inner join Purchasing.Suppliers as s on s.SupplierID = po.SupplierID
inner join Application.People as p on p.PersonID = po.ContactPersonID
where dm.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight')
	and ExpectedDeliveryDate between '2013-01-01' and '2013-01-31'
	and IsOrderFinalized = 1

/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/
select top 10 o.OrderID
	,c.CustomerName
	,p.FullName as SalesPerson
from Sales.Orders as o
inner join Sales.Customers as c on c.CustomerID = o.CustomerID
inner join Application.People as p on p.PersonID = o.SalespersonPersonID
order by o.OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select distinct o.CustomerID
	,c.CustomerName
	,c.PhoneNumber
from Sales.Orders as o
inner join Sales.OrderLines as ol on ol.OrderID = o.OrderID
inner join Warehouse.StockItems as si on si.StockItemID = ol.StockItemID
inner join Sales.Customers as c on c.CustomerID = o.CustomerID
where si.StockItemName = 'Chocolate frogs 250g'

/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/
select year(i.InvoiceDate)		as InvoiceYear
	,month(i.InvoiceDate)		as InvoiceMonth
	,avg(il.UnitPrice)			as AvgPrice
	,sum(il.ExtendedPrice)		as SumInvoices
from Sales.Invoices as i
inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
group by year(i.InvoiceDate)	
	,month(i.InvoiceDate)

/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(i.InvoiceDate)		as InvoiceYear
	,month(i.InvoiceDate)		as InvoiceMonth
	,sum(il.UnitPrice * il.Quantity) as SumInvoices
from Sales.Invoices as i
inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
group by year(i.InvoiceDate)	
	,month(i.InvoiceDate)
having sum(il.UnitPrice * il.Quantity) > 10000


/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

select year(i.InvoiceDate)	as InvoiceYear
	,month(i.InvoiceDate)	as InvoiceMonth
	,si.StockItemName			as ItemName
	,sum(il.UnitPrice * il.Quantity) 	as ItemSales
	,min(i.InvoiceDate)		as DateFirstSaleInMonth
	,sum(Quantity)				as ItemSaledQuantity
from Sales.Invoices as i
inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
inner join Warehouse.StockItems as si on si.StockItemID = il.StockItemID
group by year(i.InvoiceDate)	
	,month(i.InvoiceDate)
	,si.StockItemName
having sum(Quantity) < 50

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

