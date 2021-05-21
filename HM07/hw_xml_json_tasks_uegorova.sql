/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

Задания выполняются с использованием базы данных WideWorldImporters.
-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------
*/

USE WideWorldImporters

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/



/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Опционально - если вы знакомы с insert, update, merge, то загрузить эти данные в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 
*/

declare @xml xml
select @xml = BulkColumn from openrowset (bulk 'C:\U\4 OTUS SQL\XML\StockItems.xml', SINGLE_CLOB) as data 
--select @xml

declare @doc int
exec sp_xml_preparedocument @doc OUTPUT, @xml

create table #NewStockItems 
(
	StockItemName nvarchar(100),
	SupplierID int,
	UnitPackageID int,
	OuterPackageID int,
	LeadTimeDays int,
	QuantityPerOuter int,
	IsChillerStock bit,
	TaxRate decimal(18, 3),
	UnitPrice decimal(18, 2),
	TypicalWeightPerUnit decimal(18, 3)
)

insert into #NewStockItems
select *
from OPENXML(@doc, N'/StockItems/Item')
with ( 
	StockItemName nvarchar(100) '@Name',
	SupplierID int 'SupplierID',
	UnitPackageID int 'Package/UnitPackageID',
	OuterPackageID int 'Package/OuterPackageID',
	LeadTimeDays int 'LeadTimeDays',
	QuantityPerOuter int 'Package/QuantityPerOuter',
	IsChillerStock bit 'IsChillerStock',
	TaxRate decimal(18, 3) 'TaxRate',
	UnitPrice decimal(18, 2) 'UnitPrice',
	TypicalWeightPerUnit decimal(18, 3) 'Package/TypicalWeightPerUnit'
	)

merge Warehouse.StockItems as tgt
using ( select StockItemName
			,SupplierID
			,UnitPackageID
			,OuterPackageID
			,LeadTimeDays
			,QuantityPerOuter
			,IsChillerStock
			,TaxRate
			,UnitPrice
			,TypicalWeightPerUnit
		from #NewStockItems) as src on src.StockItemName COLLATE Cyrillic_General_CI_AS = tgt.StockItemName
when matched then
	update set tgt.SupplierID					= src.SupplierID
				,tgt.UnitPackageID				= src.UnitPackageID
				,tgt.OuterPackageID				= src.OuterPackageID
				,tgt.LeadTimeDays					= src.LeadTimeDays
				,tgt.QuantityPerOuter			= src.QuantityPerOuter
				,tgt.IsChillerStock				= src.IsChillerStock
				,tgt.TaxRate						= src.TaxRate
				,tgt.UnitPrice						= src.UnitPrice
				,tgt.TypicalWeightPerUnit		= src.TypicalWeightPerUnit
when not matched then 
	insert (StockItemName
			,SupplierID
			,ColorID
			,UnitPackageID
			,OuterPackageID
			,Brand
			,Size
			,LeadTimeDays
			,QuantityPerOuter
			,IsChillerStock
			,Barcode
			,TaxRate
			,UnitPrice
			,RecommendedRetailPrice
			,TypicalWeightPerUnit
			,MarketingComments
			,InternalComments
			,Photo
			,CustomFields
			,LastEditedBy)
	values( src.StockItemName
			,src.SupplierID
			,null
			,src.UnitPackageID
			,src.OuterPackageID
			,null
			,null
			,src.LeadTimeDays
			,src.QuantityPerOuter
			,src.IsChillerStock
			,null
			,src.TaxRate
			,src.UnitPrice
			,null
			,src.TypicalWeightPerUnit
			,null
			,null
			,null
			,null
			,1);

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

select StockItemName [@Name],
	SupplierID [SupplierID],
	UnitPackageID [Package/UnitPackageID],
	OuterPackageID [Package/OuterPackageID],
	QuantityPerOuter [Package/QuantityPerOuter],
	TypicalWeightPerUnit [Package/TypicalWeightPerUnit],
	LeadTimeDays [LeadTimeDays],
	IsChillerStock [IsChillerStock],
	TaxRate [TaxRate],
	UnitPrice [UnitPrice]
from Warehouse.StockItems
for xml path('Item'), root('StockItems')

--напишите здесь свое решение


/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select StockItemID
	,StockItemName
	,JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture
	,JSON_VALUE(CustomFields, '$.Tags[0]') as FirstTag
from Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

SELECT StockItemID
	,StockItemName
	,STRING_AGG(Tags_Names.Value, ',')
FROM Warehouse.StockItems
CROSS APPLY OPENJSON(CustomFields, '$.Tags') Tags_Names
CROSS APPLY OPENJSON(CustomFields, '$.Tags') Tags
WHERE Tags.value = 'Vintage'
group by StockItemID
	,StockItemName
