/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "07 - Динамический SQL".

Задания выполняются с использованием базы данных WideWorldImporters.
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*

Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/


declare @sql nvarchar(max)
declare @ColumnName nvarchar(max) 

select @ColumnName= ISNULL(@ColumnName + ',','') + QUOTENAME(CustomerName)
from Sales.Customers as c
inner join (select distinct CustomerID from Sales.Invoices) as i on i.CustomerID = c.CustomerID

set @sql = 
N'select format(InvoiceMonth, ''dd.MM.yyyy'') as InvoiceMonth, ' + @ColumnName +'
from (select i.InvoiceID
			,c.CustomerName
			,CAST(DATEADD(mm,DATEDIFF(mm,0,i.InvoiceDate),0) AS DATE) as InvoiceMonth
		from Sales.Invoices as i
		inner join Sales.Customers as c on c.CustomerID = i.CustomerID) AS SourceTable
		pivot ( count(InvoiceID) FOR CustomerName
			in ( ' + @ColumnName + ')
) as PivotTable;'
exec sp_executesql @sql


