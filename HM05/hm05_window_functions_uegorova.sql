/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".
*/
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

select i.InvoiceID
	,c.CustomerName
	,i.InvoiceDate
	,t.TransactionAmount
	,(select sum(t.TransactionAmount) as TotalSum 
				from sales.CustomerTransactions as t 
				inner join Sales.Invoices as it on it.InvoiceID = t.InvoiceID
				where month(it.InvoiceDate) <= month(i.InvoiceDate) and year(it.InvoiceDate) <= year(i.InvoiceDate)
				and it.InvoiceDate >= '2015-01-01') a
from Sales.Invoices as i
inner join Sales.CustomerTransactions as t on t.InvoiceID = i.InvoiceID
inner join Sales.Customers as c on c.CustomerID = i.CustomerID
where i.InvoiceDate >= '2015-01-01'
order by i.InvoiceDate

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

select i.InvoiceID
	,c.CustomerName
	,i.InvoiceDate
	,t.TransactionAmount
	,sum(t.TransactionAmount) over (order by year(i.InvoiceDate), month(i.InvoiceDate))  as TotalSum
from Sales.Invoices as i
inner join Sales.CustomerTransactions as t on t.InvoiceID = i.InvoiceID
inner join Sales.Customers as c on c.CustomerID = i.CustomerID
where i.InvoiceDate >= '2015-01-01'
order by i.InvoiceDate

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/

select Month_Invoice
	,f.StockItemID
	,st.StockItemName
from (select month(i.InvoiceDate) as Month_Invoice
			,il.StockItemID
			,dense_rank() over (partition by month(i.InvoiceDate) order by sum(il.Quantity) desc) as r
		from Sales.Invoices as i
		inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
		where i.InvoiceDate between '2016-01-01' and '2016-12-31'
		group by  month(i.InvoiceDate)
			,il.StockItemID) as f
inner join Warehouse.StockItems as st on st.StockItemID = f.StockItemID
where r <=2
order by Month_Invoice


/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

select StockItemID
	,StockItemName
	,Brand
	,UnitPrice
	,Name_Number				= ROW_NUMBER() over (partition by left(StockItemName, 1) order by StockItemName)
	,Total_StockItems			= count(StockItemID) over () 
	,Name_Number				= count(StockItemID) over (partition by left(StockItemName, 1))
	,NextStockitemID			= lead(StockItemID) over (order by StockItemName)
	,PreviousStockItemID		= lead(StockItemID) over (order by StockItemName)
	,Next2Row_StockitemName = lead(StockItemName, 2, 'No items') over (order by StockItemName)
	,UnitPriceGroup			= ntile(30) over (order by TypicalWeightPerUnit)
from Warehouse.StockItems
order by StockItemName

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/
--определяем последнюю строку инвойса по дате для каждого сотрудника. Если в один день сотрудник оформил несколько инфойсов. то выберется любой

select p.PersonID
	,p.FullName
	,f.CustomerID
	,c.CustomerName
	,f.InvoiceDate
	,t.TransactionAmount
from Application.People as p
inner join (
	select  i.SalespersonPersonID
		,i.InvoiceID
		,i.InvoiceDate
		,i.CustomerID
		,row_number() over (partition by i.SalespersonPersonID order by i.InvoiceDate desc) as rn
	from Sales.Invoices as i (nolock)
	) as f on f.rn = 1 and f.SalespersonPersonID = p.PersonID
inner join Sales.CustomerTransactions as t on t.InvoiceID = f.InvoiceID
inner join Sales.Customers as c on c.CustomerID = f.CustomerID


/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
--ранжируем по цене и товару, так как разные товары могут иметь одну и ту же цену
--группировкой убираем несколько одинаковых товаров, проданных одному и тому же клиенту. Выбираем максимальную дату продажи
select f.CustomerID
	,c.CustomerName
	,f.StockItemID
	,f.UnitPrice
	,max(f.InvoiceDate) as InvoiceDate
from Sales.Customers as c 
inner join 
	(select i.CustomerID
				,il.StockItemID
				,il.UnitPrice
				,i.InvoiceDate
				,dense_rank() over (partition by CustomerID order by UnitPrice desc, il.StockItemID) as rn
			from Sales.Invoices as i 
			inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	) as f on f.CustomerID = c.CustomerID
where f.rn <=2
group by f.CustomerID
	,c.CustomerName
	,f.StockItemID
	,f.UnitPrice
order by f.CustomerID

