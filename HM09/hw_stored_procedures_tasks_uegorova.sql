/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "12 - �������� ���������, �������, ��������, �������".

������� ����������� � �������������� ���� ������ WideWorldImporters.
*/

USE WideWorldImporters

/*
�� ���� �������� �������� �������� ��������� / ������� � ������������������ �� �������������.
*/

/*
1) �������� ������� ������������ ������� � ���������� ������ �������.
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


--������ ������
--select dbo.udf_FindCustomerMaxInvoice () as Customer;


/*
2) �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
������������ ������� :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

--�� ������� ������� ������, ��� ��� ���� � ��� �� ������ ��� ��������� ��������� �������

create procedure dbo.udp_FindInvoiceOfCustomer (@�ustomerID int)
as
begin
	SET NOCOUNT ON; 
	
	select c.CustomerID, i.InvoiceID, sum(il.Quantity*il.UnitPrice) as SumInvoice
	from Sales.Customers as c
	inner join Sales.Invoices as i on i.CustomerID = c.CustomerID
	inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	where c.CustomerID = @�ustomerID
	group by c.CustomerID, i.InvoiceID

	return;
end;

--������ ������ ��� ������ � Id = 100
--execute udp_FindInvoiceOfCustomer @�ustomerID = 100

/*
3) ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.
*/

--1. ������� ���������, ����������� �� ��, ��� � ������� 2
create function dbo.udf_FindInvoiceOfCustomer (@�ustomerID int)
returns table
as
return
(
	select c.CustomerID, i.InvoiceID, sum(il.Quantity*il.UnitPrice) as SumInvoice
	from Sales.Customers as c
	inner join Sales.Invoices as i on i.CustomerID = c.CustomerID
	inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	where c.CustomerID = @�ustomerID
	group by c.CustomerID, i.InvoiceID
)

select * from udf_FindInvoiceOfCustomer (100)
execute udp_FindInvoiceOfCustomer @�ustomerID = 100

--�� ������������������ ��������� � ������� ����������, ������ ���������� ����� ��������, ������� ����� ����� �������

--2. ������� ��������� ������� �� ������ ����� ���� ������� ������� � ����� �� ���������
create function dbo.udf_FindValueCustomer (@�ustomerID int)
returns decimal(18,9)
as
begin
	declare @Value decimal(18,9)

	set @Value = (select sum(il.Quantity*il.UnitPrice)
	from Sales.Invoices as i 
	inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	where i.CustomerID = @�ustomerID)

	return @Value
end

create procedure dbo.udp_FindValueCustomer (@�ustomerID int)
as
begin
	declare @Value decimal(18,9)

	set @Value = (select sum(il.Quantity*il.UnitPrice)
	from Sales.Invoices as i 
	inner join Sales.InvoiceLines as il on il.InvoiceID = i.InvoiceID
	where i.CustomerID = @�ustomerID)

	select @Value

	return
end


select dbo.udf_FindValueCustomer (100)
execute dbo.udp_FindValueCustomer 100

--��������� �������� ������ ��������, ��� ���������� ������� �� ������������ ���� ������� ������, ������ Constant Scan, � � ��������� - ������������. 
--��������� ����� ����������� �� ������������ ����� �������, ���� ���� �������� �������� � ����� ����������� ����� ������

/*
4) �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����. 
*/

declare @CustomerId int = 1
select CustomerID
	,InvoiceID
	,SumInvoice
	,dbo.udf_FindValueCustomer (@CustomerId) as SumCustomer
from dbo.udf_FindInvoiceOfCustomer (@CustomerId)

/*
5) �����������. �� ���� ���������� ������� ����� ������� �������� ���������� �� �� ������������ � ������. 
*/
