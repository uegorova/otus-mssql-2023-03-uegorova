--1. Обязательное ограничение уникальности по натуральному ключу в справочниках, например, в [CH3_Ship_To_Code] в справочнике [DMND].[Dim_CustomerPlanning]
--2. Кластерный первичный ключ – искусственный - ID
--3.  Не кластерный индекс по натуральному ключу


USE [DWH]
GO

CREATE TABLE [DMND].[Dim_CustomerPlanning](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key clustered,
	[CH3_Ship_To_Code] [nvarchar](20) NOT NULL,
	[CH3_Ship_To_Name] [nvarchar](100) NULL,
	[CH2_Sold_To_Code] [nvarchar](20) NULL,
	[CH2_Sold_To_Name] [nvarchar](100) NULL,
	[CH1_Customer_Code] [nvarchar](20) NULL,
	[CH1_Customer_Name] [nvarchar](250) NULL,
	[Partner_Country] [nvarchar](100) NULL,
	[Partner_City] [nvarchar](100) NULL,
	[Channel_Name] [nvarchar](250) NULL,
	[Price_List_Code] [nvarchar](50) NULL,
	[Partner_Street] [nvarchar](250) NULL,
	[Partner_Region] [nvarchar](100) NULL,
	[THL2_DSM] [nvarchar](100) NULL,
	[THL2_DSM_Code] [nvarchar](20) NULL,
	[THL3_Sales_Manager] [nvarchar](100) NULL,
	[THL3_Sales_Manager_Code] [nvarchar](20) NULL,
	[THL3_Territory_Manager] [nvarchar](100) NULL,
	[THL3_Territory_Manager_Code] [nvarchar](20) NULL,
	[TOP_Classification_Name] [nvarchar](250) NULL,
	[RSD_Region] [nvarchar](100) NULL)


ALTER TABLE [DMND].[Dim_CustomerPlanning] ADD  CONSTRAINT [UK_Dim_CustomerPlanning_CH3_Ship_To_Code] UNIQUE NONCLUSTERED (	[CH3_Ship_To_Code])

--Индекс будет использоваться в запросе - добавлении нормализованных данных в таблицу фактов

begin try

	with cte_scenario
	as
		(
		select distinct s.ID as ID_Scenario 
		from SA.DemandPlanning as a
		inner join DMND.Dim_Scenario as s on s.ScenarioName = a.Scenario
		)

	delete
	from DMND.Fact_DemandPlanning
	where  ID_Scenario in (select ID_Scenario from cte_scenario)

	insert into DMND.Fact_DemandPlanning
	select sc.ID					as ID_Scenario
		,a.[Date]				as DateForecast
		,p.ID						as ID_Product
		,c.ID						as ID_CustomerPlanning
		,st.ID					as ID_SalesType
		,o.ID						as ID_OutletChain
		,pt.ID					as ID_PromoType
		,convert(decimal(18,9), replace(a.ShipmentTN , ',', '.'))		as VolumeForecastShipment
		,convert(decimal(18,9), replace(a.PODvolumeTN , ',', '.'))		as VolumePOD
		,convert(decimal(18,9), replace(a.CCPkUSD , ',', '.'))			as ValueCCP
		,convert(decimal(18,9), replace(a.PromobudjetkUSD , ',', '.')) as ValuePromoBudjet
		,convert(decimal(18,9), replace(a.NSVkUSD , ',', '.'))			as ValueNCV
		,convert(decimal(18,9), replace(a.CMAkUSD , ',', '.'))			as ValueCMA
		,a.FileLoadedName	as [FileName]
	FROM SA.DemandPlanning as a
	inner join DMND.Dim_CustomerPlanning as c on c.CH3_Ship_To_Code = a.ShiptoCode
	inner join DMND.Dim_Product as p on p.Material_No = a.MaterialNumber
	inner join DMND.Dim_OutletChain as o on o.Chain_Code = isnull(nullif(OutletChainCode, ''), '000')
	inner join DMND.Dim_PromoType as pt on pt.PromoTypeName = a.PromoType
	inner join DMND.Dim_SalesType as st on st.SalesTypeName = a.SalesType
	inner join DMND.Dim_Scenario as sc on sc.ScenarioName = a.Scenario
	inner join SALES.Dim_Calendar as d on d.[Date] = a.[Date]

end try

begin catch 

	declare @ErrorMessage NVARCHAR(4000);  
	declare @ErrorSeverity INT;  
	declare @ErrorState INT;  
  
	SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE();  

	RAISERROR (@ErrorMessage, -- Message text.  
			@ErrorSeverity, -- Severity.  
			@ErrorState -- State.  
			);  

end catch 