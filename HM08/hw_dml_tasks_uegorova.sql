/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

Задания выполняются с использованием базы данных WideWorldImporters.
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/


	insert into Sales.Customers(CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID
			,PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition
			,WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
	values
	('Eguar Toys (Sylvanite, MT)',	1,	3,	1,	1003,	1004,	3,	33475, 33475, NULL, '2013-01-01', 0.000, 0, 0, 7, '(406) 555-0100', '(406) 555-0101', '', '', 'http://www.eguars.com/Sylvanite', 'Shop 245', '705 Dita Lane', '90216', 0xE6100000010CF37A8BE2B05B4840056FA35CF5F75CC0, 'PO Box 259', 'Jogiville', '90216', 1)
	,('Eguar (Peeples Valley, AZ)',	1,	3,	1,	1005,	1006,	3,	26483, 26483, NULL, '2013-01-01', 0.000, 0, 0, 7, '(480) 555-0100', '(480) 555-0101', '', '', 'http://www.eguars.com/PeeplesValley', 'Unit 217', '1970 Khandke Road', '90205', 0xE6100000010CC97553CA6B2241404FACF82B892E5CC0,'PO Box 3648', 'Lucescuville', 	'90205', 1)
	,('Eguar (Medicine Lodge, KS)',	1,	3,	1,	1007,	1008,	3,	21692, 21692, NULL, '2013-01-01', 0.000, 0, 0, 7, '(316) 555-0100', '(316) 555-0101', '', '', 'http://www.eguars.com/MedicineLodge', 'Suite 164', '967 Riutta Boulevard',	'90152',	0xE6100000010C02261532FCA34240EDB776A224A558C0,	'PO Box 5065',	'Maciasville',	'90152',	1)
	,('Eguar (Gasport, NY)', 1, 3, 1, 1009, 1010, 3, 12748, 12748,	NULL,	'2013-01-01',	0.000, 0, 0, 7, '(212) 555-0100', '(212) 555-0101', '', '', 'http://www.eguars.com/Gasport',	'Unit 176', '1674 Skujins Boulevard', 	'90261',	0xE6100000010C5948652F80994540F93BCA77DFA453C0, 'PO Box 6294',	'Kellnerovaville',	'90261',	1)
	,('Eguar (Jessie, ND)',	1,	3,	1,	1011,	1012,	3,	17054, 17054,	NULL,	'2013-01-01',	0.000, 0, 0, 7, '(701) 555-0100', '(701) 555-0101', '', '', 'http://www.eguars.com/Jessie', 	'Shop 196',	'483 Raut Lane',	'90298',	0xE6100000010CB9A6406667C54740BD7E77E13D8F58C0,	'PO Box 571',	'Booseville',	'90298',	1)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

	delete
	from Sales.Customers
	where CustomerName = 'Eguar Toys (Sylvanite, MT)'


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

	update a
	set a.DeliveryAddressLine1 = 'Unit 111'
	from Sales.Customers as a
	where CustomerName = 'Eguar (Gasport, NY)'

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

	create table [Sales].[Customers_Add](
		[CustomerID] [int] identity (1,1) NOT NULL,
		[CustomerName] [nvarchar](100) NOT NULL,
		[BillToCustomerID] [int] NOT NULL,
		[CustomerCategoryID] [int] NOT NULL,
		[BuyingGroupID] [int] NULL,
		[PrimaryContactPersonID] [int] NOT NULL,
		[AlternateContactPersonID] [int] NULL,
		[DeliveryMethodID] [int] NOT NULL,
		[DeliveryCityID] [int] NOT NULL,
		[PostalCityID] [int] NOT NULL,
		[CreditLimit] [decimal](18, 2) NULL,
		[AccountOpenedDate] [date] NOT NULL,
		[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
		[IsStatementSent] [bit] NOT NULL,
		[IsOnCreditHold] [bit] NOT NULL,
		[PaymentDays] [int] NOT NULL,
		[PhoneNumber] [nvarchar](20) NOT NULL,
		[FaxNumber] [nvarchar](20) NOT NULL,
		[DeliveryRun] [nvarchar](5) NULL,
		[RunPosition] [nvarchar](5) NULL,
		[WebsiteURL] [nvarchar](256) NOT NULL,
		[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
		[DeliveryAddressLine2] [nvarchar](60) NULL,
		[DeliveryPostalCode] [nvarchar](10) NOT NULL,
		[DeliveryLocation] [geography] NULL,
		[PostalAddressLine1] [nvarchar](60) NOT NULL,
		[PostalAddressLine2] [nvarchar](60) NULL,
		[PostalPostalCode] [nvarchar](10) NOT NULL,
		[LastEditedBy] [int] NOT NULL,
		[ValidFrom] [datetime2](7) NOT NULL,
		[ValidTo] [datetime2](7) NOT NULL,
	)

	insert into Sales.Customers_Add(CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID
			,PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition
			,WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo)
	values
	 ('Apple Toys (Sylvanite, MT)',	1,	3,	1,	1003,	1004,	3,	33475, 33475, NULL, '2013-01-01', 0.000, 0, 0, 7, '(888) 555-0100', '(406) 555-0101', '', '', 'http://www.apple.com/Sylvanite', 'Shop 245', '705 Dita Lane', '90216', 0xE6100000010CF37A8BE2B05B4840056FA35CF5F75CC0, 'PO Box 259', 'Jogiville', '90216', 1, '2021-01-01', '9999-12-31')
	,('Apple (Peeples Valley, AZ)',	1,	3,	1,	1005,	1006,	3,	26483, 26483, NULL, '2013-01-01', 0.000, 0, 0, 7, '(888) 555-0100', '(480) 555-0101', '', '', 'http://www.apple.com/PeeplesValley', 'Unit 217', '1970 Khandke Road', '90205', 0xE6100000010CC97553CA6B2241404FACF82B892E5CC0,'PO Box 3648', 'Lucescuville', 	'90205', 1, '2021-01-01', '9999-12-31')
	,('Apple (Medicine Lodge, KS)',	1,	3,	1,	1007,	1008,	3,	21692, 21692, NULL, '2013-01-01', 0.000, 0, 0, 7, '(888) 555-0100', '(316) 555-0101', '', '', 'http://www.apple.com/MedicineLodge', 'Suite 164', '967 Riutta Boulevard',	'90152',	0xE6100000010C02261532FCA34240EDB776A224A558C0,	'PO Box 5065',	'Maciasville',	'90152',	1, '2021-01-01', '9999-12-31')
	,('Apple (Gasport, NY)', 1, 3, 1, 1009, 1010, 3, 12748, 12748,	NULL,	'2013-01-01',	0.000, 0, 0, 7, '(888) 555-0100', '(212) 555-0101', '', '', 'http://www.apple.com/Gasport',	'Unit 176', '1674 Skujins Boulevard', 	'90261',	0xE6100000010C5948652F80994540F93BCA77DFA453C0, 'PO Box 6294',	'Kellnerovaville',	'90261',	1, '2021-01-01', '9999-12-31')
	,('Eguar (Jessie, ND)',	1,	3,	1,	1011,	1012,	3,	17054, 17054,	NULL,	'2013-01-01',	0.000, 0, 0, 7, '(701) 555-0100', '(701) 555-0101', '', '', 'http://www.eguars.com/Jessie', 	'Shop 196',	'483 Raut Lane',	'90298',	0xE6100000010CB9A6406667C54740BD7E77E13D8F58C0,	'PO Box 571',	'Booseville',	'90298',	1, '2021-01-01', '9999-12-31')


	merge Sales.Customers AS tgt 
	using (select CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID
			,PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition
			,WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy
			from Sales.Customers_Add) as src 
		on tgt.CustomerName = src.CustomerName
	when matched 
		then update set tgt.BillToCustomerID = src.BillToCustomerID
      ,tgt.CustomerCategoryID				 = src.CustomerCategoryID
      ,tgt.BuyingGroupID					 = src.BuyingGroupID
      ,tgt.PrimaryContactPersonID		 = src.PrimaryContactPersonID
      ,tgt.AlternateContactPersonID		 = src.AlternateContactPersonID
      ,tgt.DeliveryMethodID				 = src.DeliveryMethodID
      ,tgt.DeliveryCityID					 = src.DeliveryCityID
      ,tgt.PostalCityID						 = src.PostalCityID
      ,tgt.CreditLimit						 = src.CreditLimit
      ,tgt.AccountOpenedDate				 = src.AccountOpenedDate
      ,tgt.StandardDiscountPercentage	 = src.StandardDiscountPercentage
      ,tgt.IsStatementSent					 = src.IsStatementSent
      ,tgt.IsOnCreditHold					 = src.IsOnCreditHold
      ,tgt.PaymentDays						 = src.PaymentDays
      ,tgt.PhoneNumber						 = src.PhoneNumber
      ,tgt.FaxNumber							 = src.FaxNumber
      ,tgt.DeliveryRun						 = src.DeliveryRun
      ,tgt.RunPosition						 = src.RunPosition
      ,tgt.WebsiteURL						 = src.WebsiteURL
      ,tgt.DeliveryAddressLine1			 = src.DeliveryAddressLine1
      ,tgt.DeliveryAddressLine2			 = src.DeliveryAddressLine2
      ,tgt.DeliveryPostalCode				 = src.DeliveryPostalCode
      ,tgt.DeliveryLocation				 = src.DeliveryLocation
      ,tgt.PostalAddressLine1				 = src.PostalAddressLine1
      ,tgt.PostalAddressLine2				 = src.PostalAddressLine2
      ,tgt.PostalPostalCode				 = src.PostalPostalCode
      ,tgt.LastEditedBy						 = src.LastEditedBy
	when not matched 
		then insert (CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID
			,PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition
			,WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy) 
			values (src.CustomerName, src.BillToCustomerID, src.CustomerCategoryID, src.BuyingGroupID, src.PrimaryContactPersonID, src.AlternateContactPersonID, src.DeliveryMethodID, src.DeliveryCityID
			,src.PostalCityID, src.CreditLimit, src.AccountOpenedDate, src.StandardDiscountPercentage, src.IsStatementSent, src.IsOnCreditHold, src.PaymentDays, src.PhoneNumber, src.FaxNumber, src.DeliveryRun, src.RunPosition
			,src.WebsiteURL, src.DeliveryAddressLine1, src.DeliveryAddressLine2, src.DeliveryPostalCode, src.DeliveryLocation, src.PostalAddressLine1, src.PostalAddressLine2, src.PostalPostalCode, src.LastEditedBy) 
	output deleted.*, $action, inserted.*;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

	exec master..xp_cmdshell 'bcp "[WideWorldImporters].Sales.Customers" out  "C:\U\OTUS\Customers1.txt" -T -w -t"@#$*" -S LAPTOP-VO3GVQQ5\SQL2019'

	create table [Sales].[Customers_Copy](
		[CustomerID] [int] NOT NULL,
		[CustomerName] [nvarchar](100) NOT NULL,
		[BillToCustomerID] [int] NOT NULL,
		[CustomerCategoryID] [int] NOT NULL,
		[BuyingGroupID] [int] NULL,
		[PrimaryContactPersonID] [int] NOT NULL,
		[AlternateContactPersonID] [int] NULL,
		[DeliveryMethodID] [int] NOT NULL,
		[DeliveryCityID] [int] NOT NULL,
		[PostalCityID] [int] NOT NULL,
		[CreditLimit] [decimal](18, 2) NULL,
		[AccountOpenedDate] [date] NOT NULL,
		[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
		[IsStatementSent] [bit] NOT NULL,
		[IsOnCreditHold] [bit] NOT NULL,
		[PaymentDays] [int] NOT NULL,
		[PhoneNumber] [nvarchar](20) NOT NULL,
		[FaxNumber] [nvarchar](20) NOT NULL,
		[DeliveryRun] [nvarchar](5) NULL,
		[RunPosition] [nvarchar](5) NULL,
		[WebsiteURL] [nvarchar](256) NOT NULL,
		[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
		[DeliveryAddressLine2] [nvarchar](60) NULL,
		[DeliveryPostalCode] [nvarchar](10) NOT NULL,
		[DeliveryLocation] [geography] NULL,
		[PostalAddressLine1] [nvarchar](60) NOT NULL,
		[PostalAddressLine2] [nvarchar](60) NULL,
		[PostalPostalCode] [nvarchar](10) NOT NULL,
		[LastEditedBy] [int] NOT NULL,
		[ValidFrom] [datetime2](7) NOT NULL,
		[ValidTo] [datetime2](7) NOT NULL,
	)


	BULK INSERT [WideWorldImporters].[Sales].[Customers_Copy]
				   FROM "C:\U\OTUS\Customers1.txt"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '@#$*',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );