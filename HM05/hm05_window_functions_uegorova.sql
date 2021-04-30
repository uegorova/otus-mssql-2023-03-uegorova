/*
�������� ������� �� ����� MS SQL Server Developer � OTUS.

������� "06 - ������� �������".
*/
-- ---------------------------------------------------------------------------
-- ������� - �������� ������� ��� ��������� ��������� ���� ������.
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. ������� ������ ����� ������ ����������� ������ �� ������� � 2015 ���� 
(� ������ ������ ������ �� ����� ����������, ��������� ����� � ������� ������� �������).
��������: id �������, �������� �������, ���� �������, ����� �������, ����� ����������� ������

������:
-------------+----------------------------
���� ������� | ����������� ���� �� ������
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
������� ����� ����� �� ������� Invoices.
����������� ���� ������ ���� ��� ������� �������.
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
2. �������� ������ ����� ����������� ������ � ���������� ������� � ������� ������� �������.
   �������� ������������������ �������� 1 � 2 � ������� set statistics time, io on
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
3. ������� ������ 2� ����� ���������� ��������� (�� ���������� ���������) 
� ������ ������ �� 2016 ��� (�� 2 ����� ���������� �������� � ������ ������).
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
4. ������� ����� ��������
���������� �� ������� ������� (� ����� ����� ������ ������� �� ������, ��������, ����� � ����):
* ������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
* ���������� ����� ���������� ������� � �������� ����� � ���� �� �������
* ���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
* ���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� ����� 
* ���������� �� ������ � ��� �� �������� ����������� (�� �����)
* �������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
* ����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��

��� ���� ������ �� ����� ������ ������ ��� ������������� �������.
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
5. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������.
   � ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������.
*/
--���������� ��������� ������ ������� �� ���� ��� ������� ����������. ���� � ���� ���� ��������� ������� ��������� ��������. �� ��������� �����

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
6. �������� �� ������� ������� ��� ����� ������� ������, ������� �� �������.
� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������.
*/
--��������� �� ���� � ������, ��� ��� ������ ������ ����� ����� ���� � �� �� ����
--������������ ������� ��������� ���������� �������, ��������� ������ � ���� �� �������. �������� ������������ ���� �������
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

