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

select * from udf_FindInvoiceOfCustomer (100)
execute udp_FindInvoiceOfCustomer @СustomerID = 100

--По производительности процедура и функция одинаковые, строят одинаковые планы запросов, которые сразу можно увидеть

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
--Процедура будет выполняться по построенному плану запроса, даже если ситуация меняется и более оптимальным будет другой

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/

declare @CustomerId int = 1
select CustomerID
	,InvoiceID
	,SumInvoice
	,dbo.udf_FindValueCustomer (@CustomerId) as SumCustomer
from dbo.udf_FindInvoiceOfCustomer (@CustomerId)

/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
