/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/
create function dbo.udf_FindCustomerMaxInvoice ()
returns nvarchar(100)
as
begin

	declare @CustomerMax nvarchar(100) = ''

	;with cte_sum
	as (
	select il.InvoiceId, sum(il.Quantity*il.UnitPrice) as SumInvoice
	from Sales.InvoiceLines as il
	group by il.InvoiceId
	)

	select @CustomerMax = c.CustomerName
	from Sales.Customers as c
	inner join Sales.Invoices as i on i.CustomerID = c.CustomerID
	inner join cte_sum as ils on ils.InvoiceID = i.InvoiceID
	where ils.SumInvoice = (select max(SumInvoice) from cte_sum)

	return @CustomerMax;

end;


--пример вызова
--select dbo.udf_FindCustomerMaxInvoice () as Customer;


/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

--за покупку считаем инвойс, так как один и тот же клиент мог совершать несколько покупок

create procedure dbo.udp_FindInvoiceOfCustomer (@СustomerID int)
as
begin
	SET NOCOUNT ON; 
	
	select c.CustomerID, i.InvoiceID, sum(il.Quantity*il.UnitPrice) as SumInvoice
	from Sales.Customers as c
	inner join Sales.Invoices as i on i.CustomerID = c.CustomerID
	inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	where c.CustomerID = @СustomerID
	group by c.CustomerID, i.InvoiceID

	return;
end;

--пример вызова для клинта с Id = 100
--execute udp_FindInvoiceOfCustomer @СustomerID = 100

/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

--1. Создала процедуру, выполняющую то же, что и задание 2
create function dbo.udf_FindInvoiceOfCustomer (@СustomerID int)
returns table
as
return
(
	select c.CustomerID, i.InvoiceID, sum(il.Quantity*il.UnitPrice) as SumInvoice
	from Sales.Customers as c
	inner join Sales.Invoices as i on i.CustomerID = c.CustomerID
	inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	where c.CustomerID = @СustomerID
	group by c.CustomerID, i.InvoiceID
)

set statistics time, io on 
select * from udf_FindInvoiceOfCustomer (100)
execute udp_FindInvoiceOfCustomer @СustomerID = 100

--Процедура и функция строят одинаковые планы запросов, разделяя Rlative Cost 50/50 но выполнение по времени разное:
--Функция 

-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 0 ms.
--SQL Server parse and compile time: 
--   CPU time = 10 ms, elapsed time = 10 ms.

-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 0 ms.

--(104 rows affected)
--Table 'InvoiceLines'. Scan count 2, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 161, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'InvoiceLines'. Segment reads 1, segment skipped 0.
--Table 'Invoices'. Scan count 1, logical reads 3, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'Customers'. Scan count 0, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

--(1 row affected)

-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 73 ms.

---процедура
-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 0 ms.
--SQL Server parse and compile time: 
--   CPU time = 0 ms, elapsed time = 0 ms.

-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 0 ms.
--Table 'InvoiceLines'. Scan count 2, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 161, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'InvoiceLines'. Segment reads 1, segment skipped 0.
--Table 'Invoices'. Scan count 1, logical reads 3, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
--Table 'Customers'. Scan count 0, logical reads 2, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 150 ms.

-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 0 ms.

-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 150 ms.
--SQL Server parse and compile time: 
--   CPU time = 0 ms, elapsed time = 0 ms.

-- SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 0 ms.

--из вышеприведенного видно, при данном объеме данных функция использует больше CPU time, а процедура Elapsed Time.


--2. Создала скалярную функцию по поиску суммы всех покупок клиента и такую же процедуру
create function dbo.udf_FindValueCustomer (@СustomerID int)
returns decimal(18,9)
as
begin
	declare @Value decimal(18,9)

	set @Value = (select sum(il.Quantity*il.UnitPrice)
	from Sales.Invoices as i 
	inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	where i.CustomerID = @СustomerID)

	return @Value
end

create procedure dbo.udp_FindValueCustomer (@СustomerID int)
as
begin
	declare @Value decimal(18,9)

	set @Value = (select sum(il.Quantity*il.UnitPrice)
	from Sales.Invoices as i 
	inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	where i.CustomerID = @СustomerID)

	select @Value

	return
end


select dbo.udf_FindValueCustomer (100)
execute dbo.udp_FindValueCustomer 100

--процедура забирает больше ресурсов, при выполнении функции не отображается план запроса внутри, только Constant Scan, а в процедуре - отображается. 
--Процедура будет выполняться по построенному плану запроса, даже если ситуация меняется и более оптимальным будет другой план запроса

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/


select a.CustomerID
	,InvoiceID
	,SumInvoice
from Sales.Customers as b 
cross apply dbo.udf_FindInvoiceOfCustomer(CustomerID) as a

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
