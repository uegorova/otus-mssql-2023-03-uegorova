--��������� �������� ���������
--���������� ��������.
--������ ������

--�������� �������� ��������� ������������ ������� � ��������� ������� ������ �������. 
--�������� �������� ��������� � ��������  ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
--������������ ������� : Sales.Customers
--Sales.Invoices
--  Sales.InvoiceLines


create procedure sp_GetCustomerWithMaxInvoice 
as
	
	with cte_sum
	as (
	select il.InvoiceId, sum(il.Quantity*il.UnitPrice) as SumInvoice
	from Sales.InvoiceLines as il
	group by il.InvoiceId
	)

	select c.CustomerName
	from Sales.Customers as c
	inner join Sales.Invoices as i on i.CustomerID = c.CustomerID
	inner join cte_sum as ils on ils.InvoiceID = i.InvoiceID
	where ils.SumInvoice = (select max(SumInvoice) from cte_sum)

	return;
go


--execute sp_GetCustomerWithMaxInvoice