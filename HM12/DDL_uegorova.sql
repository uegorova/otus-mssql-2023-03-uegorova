--создаем базу
USE master; 
GO 
IF DB_ID (N'test2') IS NOT NULL 
	DROP DATABASE MyProject; 
GO 

CREATE DATABASE MyProject
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = test2, FILENAME = N'C:\SQL\MyProject.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
 LOG ON 
( NAME = test2_log, FILENAME = N'C:\SQL\MyProject_log.ldf' , 
	SIZE = 8MB , 
	MAXSIZE = 10GB , 
	FILEGROWTH = 65536KB );

--создаем схему
CREATE SCHEMA DMND

--создаем таблицу сетей с первичным ключом по ID
CREATE TABLE [DMND].[Dim_OutletChain](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED,
	[Outlet Chain Name] [nvarchar](100) NULL,
	[Chain_VC_CY] [nvarchar](50) NULL,
	[Chain_Code] [nvarchar](50) NULL,
	[Chain_VC_NY] [nvarchar](50) NULL,
	[Chain_VC_PPY] [nvarchar](50) NULL,
	[Chain_VC_PY] [nvarchar](50) NULL,
	[Chain RKAM] [nvarchar](100) NULL)

--накладываем ограничение уникальности  по натуральному ключу
ALTER TABLE [DMND].[Dim_OutletChain] ADD CONSTRAINT [UK_Dim_OutletChain_OutletChainCode] UNIQUE NONCLUSTERED ([Chain_Code] ASC)

--создаем индекс для поиска совдадений при добавлении новых значений
CREATE NONCLUSTERED INDEX NIX_Dim_OutletChain_Chain_Code ON [DMND].[Dim_OutletChain] ([Chain_Code])

--создаем таблицу клиентов
CREATE TABLE [DMND].[Dim_CustomerPlanning](
	[ID] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY CLUSTERED ,
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
	[RSD_Region] [nvarchar](100) NULL )

--накладываем ограничение уникальности
ALTER TABLE [DMND].[Dim_CustomerPlanning] ADD CONSTRAINT [UK_Dim_CustomerPlanning_CH3_Ship_To_Code] UNIQUE NONCLUSTERED ([Chain_Code] ASC)

--создаем индекс для поиска совдадений при добавлении новых значений
CREATE NONCLUSTERED INDEX NIX_Dim_CustomerPlanning_CH3_Ship_To_Code ON [DMND].[Dim_CustomerPlanning] ([CH3_Ship_To_Code])

---по тем же принципам создаем таблицы [DMND].[Dim_Product], [DMND].[Dim_PromoType], [DMND].[Dim_SalesType], [DMND].[Dim_Scenario]

--созлаем таблицу фактов


CREATE TABLE [DMND].[Fact_DemandPlanning](
	[ID_Scenario] [int] NOT NULL,
	[DateForecast] [date] NOT NULL,
	[ID_Product] [int] NOT NULL,
	[ID_CustomerPlanning] [int] NOT NULL,
	[ID_SalesType] [int] NOT NULL,
	[ID_OutletChain] [int] NOT NULL,
	[ID_PromoType] [int] NOT NULL,
	[VolumeForecastShipment] [decimal](18, 9) NOT NULL,
	[VolumePOD] [decimal](18, 9) NULL,
	[ValueCCP] [decimal](18, 9) NULL,
	[ValuePromoBudjet] [decimal](18, 9) NULL,
	[ValueNCV] [decimal](18, 9) NULL,
	[ValueCMA] [decimal](18, 9) NULL,
	[FileName] [nvarchar](255) NULL
) 

ALTER TABLE [DMND].[Fact_DemandPlanning]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DemandPlanning_CustomerPlanning] FOREIGN KEY([ID_CustomerPlanning]) REFERENCES [DMND].[Dim_CustomerPlanning] ([ID])
ALTER TABLE [DMND].[Fact_DemandPlanning]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DemandPlanning_DateForecast] FOREIGN KEY([DateForecast]) REFERENCES [SALES].[Dim_Calendar] ([Date])
ALTER TABLE [DMND].[Fact_DemandPlanning]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DemandPlanning_OutletChain] FOREIGN KEY([ID_OutletChain]) REFERENCES [DMND].[Dim_OutletChain] ([ID])
ALTER TABLE [DMND].[Fact_DemandPlanning]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DemandPlanning_Product] FOREIGN KEY([ID_Product]) REFERENCES [DMND].[Dim_Product] ([ID])
ALTER TABLE [DMND].[Fact_DemandPlanning]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DemandPlanning_PromoType] FOREIGN KEY([ID_PromoType]) REFERENCES [DMND].[Dim_PromoType] ([ID])
ALTER TABLE [DMND].[Fact_DemandPlanning]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DemandPlanning_SalesType] FOREIGN KEY([ID_SalesType]) REFERENCES [DMND].[Dim_SalesType] ([ID])
ALTER TABLE [DMND].[Fact_DemandPlanning]  WITH CHECK ADD  CONSTRAINT [FK_Fact_DemandPlanning_Scenario] FOREIGN KEY([ID_Scenario]) REFERENCES [DMND].[Dim_Scenario] ([ID])
