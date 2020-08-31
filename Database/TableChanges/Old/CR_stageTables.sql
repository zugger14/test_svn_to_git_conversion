/* Author : Vishwas Khanal
   Dated : 11.24.2009
   Desc  : SSIS Staging tables
*/
IF OBJECT_ID('[dbo].[stage_source_price_curve_nymex]','u') IS NOT NULL
DROP TABLE [dbo].[stage_source_price_curve_nymex]
GO
IF OBJECT_ID('[dbo].[stage_source_price_curve_platts]','u') IS NOT NULL
DROP TABLE [dbo].[stage_source_price_curve_platts]
GO
IF OBJECT_ID('[dbo].[stage_source_price_curve_treasury]','u') IS NOT NULL
DROP TABLE [dbo].[stage_source_price_curve_treasury]
GO

CREATE TABLE [dbo].[stage_source_price_curve_nymex](
	[asOfDate] [varchar](100) NULL,
	[MaturityDate] [varchar](100) NULL,
	[Open] [varchar](100) NULL,
	[High] [varchar](100) NULL,
	[Low] [varchar](100) NULL,
	[Last] [varchar](100) NULL,
	[Change] [varchar](100) NULL,
	[Settle] [varchar](100) NULL,
	[Volume] [varchar](100) NULL,
	[OpenInterest] [varchar](100) NULL
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[stage_source_price_curve_platts](
	[flag] [varchar](50) NULL,
	[details] [varchar](8000) NULL,
	[index] [varchar](100) NULL,
--	[asOfDate] [varchar](100) NULL,
	[update_ts] [varchar](100) NULL
) ON [PRIMARY]


GO

CREATE TABLE [dbo].[stage_source_price_curve_treasury](
	[asOfdate] [nvarchar](255) NULL,
	[1mo] [nvarchar](255) NULL,
	[3mo] [nvarchar](255) NULL,
	[6mo] [nvarchar](255) NULL,
	[1yr] [nvarchar](255) NULL,
	[2yr] [nvarchar](255) NULL,
	[3yr] [nvarchar](255) NULL,
	[5yr] [nvarchar](255) NULL,
	[7yr] [nvarchar](255) NULL,
	[10yr] [nvarchar](255) NULL,
	[20yr] [nvarchar](255) NULL,
	[30yr] [nvarchar](255) NULL,
	[30yrDisplay] [nvarchar](255) NULL,
	[id] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
