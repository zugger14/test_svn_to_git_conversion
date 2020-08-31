/*
Author : Vishwas Khanal
Dated  : Nov.03.2009
Desc   : Creation of all the staging tables required for SSIS package
*/
IF OBJECT_ID('stage_source_price_curve_nymex','u') IS NULL
CREATE TABLE [dbo].[stage_source_price_curve_nymex](
	[asOfDate] [varchar](50) NULL,
	[MaturityDate] [varchar](50) NULL,
	[Last] [varchar](50) NULL,
	[openHigh] [varchar](50) NULL,
	[openLow] [varchar](50) NULL,
	[High] [varchar](50) NULL,
	[Low] [varchar](50) NULL,
	[MostRecentSettle] [varchar](50) NULL,
	[change] [varchar](50) NULL,
	[openInterest] [varchar](50) NULL,
	[estimatedVolume] [varchar](50) NULL,
	[lastUpdated] [varchar](50) NULL
) ON [PRIMARY]

GO

IF OBJECT_ID('stage_source_price_curve_platts','u') IS NULL
CREATE TABLE [dbo].[stage_source_price_curve_platts](
	[flag] [varchar](50) NULL,
	[details] [varchar](8000) NULL,
	--[maturitydate] [varchar](100) NULL,
	[index] VARCHAR(100) NULL,
	[asOfDate] [varchar](100) NULL
) ON [PRIMARY]

