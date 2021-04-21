/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/
;with cte_Customer as
(
select CustomerID
	,substring(CustomerName, CHARINDEX('(', CustomerName) + 1, CHARINDEX( ')', CustomerName) - CHARINDEX('(', CustomerName)  -1 ) as CustomerName
from Sales.Customers
where CustomerID between 2 and 6
)

SELECT format(InvoiceMonth, 'dd.MM.yyyy') as InvoiceMonth, [Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND]
FROM (select i.InvoiceID
			,C.CustomerName
			,CAST(DATEADD(mm,DATEDIFF(mm,0,i.InvoiceDate),0) AS DATE) as InvoiceMonth
		from Sales.Invoices as i
		inner join cte_Customer as c on c.CustomerID = i.CustomerID) AS SourceTable
		PIVOT ( count(InvoiceID) FOR CustomerName
			IN ( [Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND])
) AS PivotTable;


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

select CustomerName
	,AddressLine
from (
		select CustomerName
			,DeliveryAddressLine1
			,DeliveryAddressLine2
			,PostalAddressLine1
			,PostalAddressLine2
		from Sales.Customers
		where CustomerName like '%Tailspin Toys%'
	) as AddressLine
UNPIVOT (AddressLine FOR AddressType IN (DeliveryAddressLine1, DeliveryAddressLine2, PostalAddressLine1, PostalAddressLine2)) AS unpt;



/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/
select CountryID
	,CountryName
	,Code
from
	(select CountryID
		,CountryName
		,IsoAlpha3Code
		,cast(IsoNumericCode as nvarchar(3)) as IsoNumericCode
	from Application.Countries) as CustomerCode
	unpivot (CustomerCode FOR Code in (IsoAlpha3Code,IsoNumericCode)) as unpvt

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
select c.CustomerID, CustomerName, StockItemID, UnitPrice, InvoiceDate
from sales.Customers as c
cross apply (
	select top 2 i.CustomerID, il.StockItemID, il.UnitPrice, max(i.InvoiceDate) as InvoiceDate
	from sales.Invoices as i
	inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	where c.CustomerID = i.CustomerID
	group by i.CustomerID, il.StockItemID, il.UnitPrice
	order by i.CustomerID, UnitPrice desc) as cr