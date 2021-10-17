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

set statistics time, io on 
select * from udf_FindInvoiceOfCustomer (100)
execute udp_FindInvoiceOfCustomer @�ustomerID = 100

--��������� � ������� ������ ���������� ����� ��������, �������� Rlative Cost 50/50 �� ���������� �� ������� ������:
--������� 

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

---���������
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

--�� ���������������� �����, ��� ������ ������ ������ ������� ���������� ������ CPU time, � ��������� Elapsed Time.


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
--��������� ����� ����������� �� ������������ ����� �������, ���� ���� �������� �������� � ����� ����������� ����� ������ ���� �������

/*
4) �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����. 
*/


select a.CustomerID
	,InvoiceID
	,SumInvoice
from Sales.Customers as b 
cross apply dbo.udf_FindInvoiceOfCustomer(CustomerID) as a

/*
5) �����������. �� ���� ���������� ������� ����� ������� �������� ���������� �� �� ������������ � ������. 
*/
