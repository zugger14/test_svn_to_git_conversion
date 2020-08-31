-- ===============================================================================================================
-- Create date: 2012-03-01
-- Description:	This script will drop all views & tables from ARCHIVE server and create ARCH1 & ARCH2 table for price curve & Position tables
-- IMPORTANT: This script should only run at archive server 
-- ===============================================================================================================

DECLARE @server_name VARCHAR(100)
DECLARE @user_name VARCHAR(100) 
DECLARE @password VARCHAR(100)
DECLARE	@db_name VARCHAR(100)


SET @server_name =  'manaslu\instance2008'
SET	@user_name	= 'farrms_admin'
SET @password = 'Admin2929'
SET @db_name = 'TRMtracker_Essent'

-----To Drop All views 
--DECLARE @viewName varchar(500)
--DECLARE cur CURSOR
--      FOR SELECT [name] FROM sys.objects WHERE type = 'v'
--      OPEN cur

--      FETCH NEXT FROM cur INTO @viewName
--      WHILE @@fetch_status = 0
--      BEGIN
--            EXEC('DROP VIEW ' + @viewName)
--            FETCH NEXT FROM cur INTO @viewName
--      END
--      CLOSE cur
--      DEALLOCATE cur

---- To Drop All tables 
----EXEC sp_msforeachtable 'DROP TABLE ?'

---- CREATE SOURCE_PRICE_CURVE_ARCH1
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[source_price_curve_arch1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_price_curve_arch1](
	[source_curve_def_id] [int] NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[Assessment_curve_type_value_id] [int] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[maturity_date] [datetime] NOT NULL,
	[curve_value] [float] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[bid_value] [float] NULL,
	[ask_value] [float] NULL,
	[is_dst] [int] NOT NULL
) 
GO
SET ANSI_PADDING OFF
GO


---- CREATE SOURCE_PRICE_CURVE_ARCH2
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[source_price_curve_arch2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_price_curve_arch2](
	[source_curve_def_id] [int] NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[Assessment_curve_type_value_id] [int] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[maturity_date] [datetime] NOT NULL,
	[curve_value] [float] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[bid_value] [float] NULL,
	[ask_value] [float] NULL,
	[is_dst] [int] NOT NULL
) 
GO
SET ANSI_PADDING OFF
GO

-----TO CREATE DELTA_REPORT_HOURLY_POSITION_ARCH1 Table 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[delta_report_hourly_position_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[delta_report_hourly_position_arch1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[delta_report_hourly_position_arch1](
	[as_of_date] [datetime] NULL,
	[partition_value] [int] NULL,
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[deal_date] [datetime] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_volume_uom_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[hr1] [numeric](38, 20) NULL,
	[hr2] [numeric](38, 20) NULL,
	[hr3] [numeric](38, 20) NULL,
	[hr4] [numeric](38, 20) NULL,
	[hr5] [numeric](38, 20) NULL,
	[hr6] [numeric](38, 20) NULL,
	[hr7] [numeric](38, 20) NULL,
	[hr8] [numeric](38, 20) NULL,
	[hr9] [numeric](38, 20) NULL,
	[hr10] [numeric](38, 20) NULL,
	[hr11] [numeric](38, 20) NULL,
	[hr12] [numeric](38, 20) NULL,
	[hr13] [numeric](38, 20) NULL,
	[hr14] [numeric](38, 20) NULL,
	[hr15] [numeric](38, 20) NULL,
	[hr16] [numeric](38, 20) NULL,
	[hr17] [numeric](38, 20) NULL,
	[hr18] [numeric](38, 20) NULL,
	[hr19] [numeric](38, 20) NULL,
	[hr20] [numeric](38, 20) NULL,
	[hr21] [numeric](38, 20) NULL,
	[hr22] [numeric](38, 20) NULL,
	[hr23] [numeric](38, 20) NULL,
	[hr24] [numeric](38, 20) NULL,
	[hr25] [numeric](38, 20) NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,
	[delta_type] [int] NULL,
	[expiration_date] [datetime] NULL,
	[deal_status_id] [int] NULL
) 
GO
SET ANSI_PADDING OFF
GO



-----TO CREATE DELTA_REPORT_HOURLY_POSITION_ARCH2 Table 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[delta_report_hourly_position_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[delta_report_hourly_position_arch2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[delta_report_hourly_position_arch2](
	[as_of_date] [datetime] NULL,
	[partition_value] [int] NULL,
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[deal_date] [datetime] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_volume_uom_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[hr1] [numeric](38, 20) NULL,
	[hr2] [numeric](38, 20) NULL,
	[hr3] [numeric](38, 20) NULL,
	[hr4] [numeric](38, 20) NULL,
	[hr5] [numeric](38, 20) NULL,
	[hr6] [numeric](38, 20) NULL,
	[hr7] [numeric](38, 20) NULL,
	[hr8] [numeric](38, 20) NULL,
	[hr9] [numeric](38, 20) NULL,
	[hr10] [numeric](38, 20) NULL,
	[hr11] [numeric](38, 20) NULL,
	[hr12] [numeric](38, 20) NULL,
	[hr13] [numeric](38, 20) NULL,
	[hr14] [numeric](38, 20) NULL,
	[hr15] [numeric](38, 20) NULL,
	[hr16] [numeric](38, 20) NULL,
	[hr17] [numeric](38, 20) NULL,
	[hr18] [numeric](38, 20) NULL,
	[hr19] [numeric](38, 20) NULL,
	[hr20] [numeric](38, 20) NULL,
	[hr21] [numeric](38, 20) NULL,
	[hr22] [numeric](38, 20) NULL,
	[hr23] [numeric](38, 20) NULL,
	[hr24] [numeric](38, 20) NULL,
	[hr25] [numeric](38, 20) NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,
	[delta_type] [int] NULL,
	[expiration_date] [datetime] NULL,
	[deal_status_id] [int] NULL
) 
GO
SET ANSI_PADDING OFF
GO
---To Create REPORT_HOURLY_POSITION_BREAKDOWN_ARCH1
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_breakdown_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[report_hourly_position_breakdown_arch1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_hourly_position_breakdown_arch1](
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[deal_date] [datetime] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_volume_uom_id] [int] NULL,
	[physical_financial_flag] [nchar](10) NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,
	[calc_volume] [numeric](38, 20) NULL,
	[term_end] [datetime] NULL,
	[expiration_date] [datetime] NULL,
	[deal_status_id] [int] NULL,
	[formula] [varchar](100) NULL
) 
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_commodity_id] ON [dbo].[report_hourly_position_breakdown_arch1] 
(
	[commodity_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_counterparty_id] ON [dbo].[report_hourly_position_breakdown_arch1] 
(
	[counterparty_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO

CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_deal_date] ON [dbo].[report_hourly_position_breakdown_arch1] 
(
	[deal_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
GO

CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_fas_book_id] ON [dbo].[report_hourly_position_breakdown_arch1] 
(
	[fas_book_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO

CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_source_system_book_id] ON [dbo].[report_hourly_position_breakdown_arch1] 
(
	[source_system_book_id1] ASC,
	[source_system_book_id2] ASC,
	[source_system_book_id3] ASC,
	[source_system_book_id4] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO

CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_volume_uom_id] ON [dbo].[report_hourly_position_breakdown_arch1] 
(
	[deal_volume_uom_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO

CREATE UNIQUE NONCLUSTERED INDEX [unique_indx_report_hourly_position_breakdown] ON [dbo].[report_hourly_position_breakdown_arch1] 
(
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[term_start] ASC,
	[term_end] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO

---To Create REPORT_HOURLY_POSITION_BREAKDOWN_ARCH2
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_breakdown_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[report_hourly_position_breakdown_arch2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_hourly_position_breakdown_arch2](
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[deal_date] [datetime] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_volume_uom_id] [int] NULL,
	[physical_financial_flag] [nchar](10) NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,
	[calc_volume] [numeric](38, 20) NULL,
	[term_end] [datetime] NULL,
	[expiration_date] [datetime] NULL,
	[deal_status_id] [int] NULL,
	[formula] [varchar](100) NULL
) 
GO
SET ANSI_PADDING OFF
GO
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_commodity_id] ON [dbo].[report_hourly_position_breakdown_arch2] 
(
	[commodity_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_counterparty_id] ON [dbo].[report_hourly_position_breakdown_arch2] 
(
	[counterparty_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO

CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_deal_date] ON [dbo].[report_hourly_position_breakdown_arch2] 
(
	[deal_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
GO

CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_fas_book_id] ON [dbo].[report_hourly_position_breakdown_arch2] 
(
	[fas_book_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO

CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_source_system_book_id] ON [dbo].[report_hourly_position_breakdown_arch2] 
(
	[source_system_book_id1] ASC,
	[source_system_book_id2] ASC,
	[source_system_book_id3] ASC,
	[source_system_book_id4] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO

CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_volume_uom_id] ON [dbo].[report_hourly_position_breakdown_arch2] 
(
	[deal_volume_uom_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO

CREATE UNIQUE NONCLUSTERED INDEX [unique_indx_report_hourly_position_breakdown] ON [dbo].[report_hourly_position_breakdown_arch2] 
(
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[term_start] ASC,
	[term_end] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) 
GO


---TO Create REPORT_HOURLY_POSITION_DEAL_ARCH1

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_deal_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[report_hourly_position_deal_arch1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_hourly_position_deal_arch1](
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[deal_date] [datetime] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_volume_uom_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[hr1] [numeric](38, 20) NULL,
	[hr2] [numeric](38, 20) NULL,
	[hr3] [numeric](38, 20) NULL,
	[hr4] [numeric](38, 20) NULL,
	[hr5] [numeric](38, 20) NULL,
	[hr6] [numeric](38, 20) NULL,
	[hr7] [numeric](38, 20) NULL,
	[hr8] [numeric](38, 20) NULL,
	[hr9] [numeric](38, 20) NULL,
	[hr10] [numeric](38, 20) NULL,
	[hr11] [numeric](38, 20) NULL,
	[hr12] [numeric](38, 20) NULL,
	[hr13] [numeric](38, 20) NULL,
	[hr14] [numeric](38, 20) NULL,
	[hr15] [numeric](38, 20) NULL,
	[hr16] [numeric](38, 20) NULL,
	[hr17] [numeric](38, 20) NULL,
	[hr18] [numeric](38, 20) NULL,
	[hr19] [numeric](38, 20) NULL,
	[hr20] [numeric](38, 20) NULL,
	[hr21] [numeric](38, 20) NULL,
	[hr22] [numeric](38, 20) NULL,
	[hr23] [numeric](38, 20) NULL,
	[hr24] [numeric](38, 20) NULL,
	[hr25] [numeric](38, 20) NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,
	[expiration_date] [datetime] NULL,
	[deal_status_id] [int] NULL
) 
GO
SET ANSI_PADDING OFF
GO

---TO Create REPORT_HOURLY_POSITION_DEAL_ARCH2

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_deal_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[report_hourly_position_deal_arch2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_hourly_position_deal_arch2](
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[deal_date] [datetime] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_volume_uom_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[hr1] [numeric](38, 20) NULL,
	[hr2] [numeric](38, 20) NULL,
	[hr3] [numeric](38, 20) NULL,
	[hr4] [numeric](38, 20) NULL,
	[hr5] [numeric](38, 20) NULL,
	[hr6] [numeric](38, 20) NULL,
	[hr7] [numeric](38, 20) NULL,
	[hr8] [numeric](38, 20) NULL,
	[hr9] [numeric](38, 20) NULL,
	[hr10] [numeric](38, 20) NULL,
	[hr11] [numeric](38, 20) NULL,
	[hr12] [numeric](38, 20) NULL,
	[hr13] [numeric](38, 20) NULL,
	[hr14] [numeric](38, 20) NULL,
	[hr15] [numeric](38, 20) NULL,
	[hr16] [numeric](38, 20) NULL,
	[hr17] [numeric](38, 20) NULL,
	[hr18] [numeric](38, 20) NULL,
	[hr19] [numeric](38, 20) NULL,
	[hr20] [numeric](38, 20) NULL,
	[hr21] [numeric](38, 20) NULL,
	[hr22] [numeric](38, 20) NULL,
	[hr23] [numeric](38, 20) NULL,
	[hr24] [numeric](38, 20) NULL,
	[hr25] [numeric](38, 20) NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,
	[expiration_date] [datetime] NULL,
	[deal_status_id] [int] NULL
) 
GO
SET ANSI_PADDING OFF
GO

--To Create REPORT_HOURLY_POSITION_PROFILE_ARCH1

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_profile_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[report_hourly_position_profile_arch1]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_hourly_position_profile_arch1](
	[partition_value] [int] NOT NULL,
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[deal_date] [datetime] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_volume_uom_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[hr1] [numeric](38, 20) NULL,
	[hr2] [numeric](38, 20) NULL,
	[hr3] [numeric](38, 20) NULL,
	[hr4] [numeric](38, 20) NULL,
	[hr5] [numeric](38, 20) NULL,
	[hr6] [numeric](38, 20) NULL,
	[hr7] [numeric](38, 20) NULL,
	[hr8] [numeric](38, 20) NULL,
	[hr9] [numeric](38, 20) NULL,
	[hr10] [numeric](38, 20) NULL,
	[hr11] [numeric](38, 20) NULL,
	[hr12] [numeric](38, 20) NULL,
	[hr13] [numeric](38, 20) NULL,
	[hr14] [numeric](38, 20) NULL,
	[hr15] [numeric](38, 20) NULL,
	[hr16] [numeric](38, 20) NULL,
	[hr17] [numeric](38, 20) NULL,
	[hr18] [numeric](38, 20) NULL,
	[hr19] [numeric](38, 20) NULL,
	[hr20] [numeric](38, 20) NULL,
	[hr21] [numeric](38, 20) NULL,
	[hr22] [numeric](38, 20) NULL,
	[hr23] [numeric](38, 20) NULL,
	[hr24] [numeric](38, 20) NULL,
	[hr25] [numeric](38, 20) NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,
	[expiration_date] [datetime] NULL,
	[deal_status_id] [int] NULL
)

GO
SET ANSI_PADDING OFF
GO

CREATE CLUSTERED INDEX [indx_report_hourly_position_profile] ON [dbo].[report_hourly_position_profile_arch1] 
(
	[partition_value] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
GO

CREATE UNIQUE NONCLUSTERED INDEX [indx_report_hourly_position_profile_deal_id] ON [dbo].[report_hourly_position_profile_arch1] 
(
	[partition_value] ASC,
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
GO
ALTER TABLE [dbo].[report_hourly_position_profile_arch1] SET (LOCK_ESCALATION = AUTO)
GO

--To Create REPORT_HOURLY_POSITION_PROFILE_ARCH2

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_profile_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[report_hourly_position_profile_arch2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[report_hourly_position_profile_arch2](
	[partition_value] [int] NOT NULL,
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NULL,
	[deal_date] [datetime] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_volume_uom_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[hr1] [numeric](38, 20) NULL,
	[hr2] [numeric](38, 20) NULL,
	[hr3] [numeric](38, 20) NULL,
	[hr4] [numeric](38, 20) NULL,
	[hr5] [numeric](38, 20) NULL,
	[hr6] [numeric](38, 20) NULL,
	[hr7] [numeric](38, 20) NULL,
	[hr8] [numeric](38, 20) NULL,
	[hr9] [numeric](38, 20) NULL,
	[hr10] [numeric](38, 20) NULL,
	[hr11] [numeric](38, 20) NULL,
	[hr12] [numeric](38, 20) NULL,
	[hr13] [numeric](38, 20) NULL,
	[hr14] [numeric](38, 20) NULL,
	[hr15] [numeric](38, 20) NULL,
	[hr16] [numeric](38, 20) NULL,
	[hr17] [numeric](38, 20) NULL,
	[hr18] [numeric](38, 20) NULL,
	[hr19] [numeric](38, 20) NULL,
	[hr20] [numeric](38, 20) NULL,
	[hr21] [numeric](38, 20) NULL,
	[hr22] [numeric](38, 20) NULL,
	[hr23] [numeric](38, 20) NULL,
	[hr24] [numeric](38, 20) NULL,
	[hr25] [numeric](38, 20) NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,
	[expiration_date] [datetime] NULL,
	[deal_status_id] [int] NULL
)

GO
SET ANSI_PADDING OFF
GO

CREATE CLUSTERED INDEX [indx_report_hourly_position_profile] ON [dbo].[report_hourly_position_profile_arch2] 
(
	[partition_value] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
GO

CREATE UNIQUE NONCLUSTERED INDEX [indx_report_hourly_position_profile_deal_id] ON [dbo].[report_hourly_position_profile_arch2] 
(
	[partition_value] ASC,
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)
GO
ALTER TABLE [dbo].[report_hourly_position_profile_arch2] SET (LOCK_ESCALATION = AUTO)
GO

--- Creating Link Server 

IF  EXISTS (SELECT srv.name FROM sys.servers srv WHERE srv.server_id != 0 AND srv.name = N'FARRMS.MAIN')EXEC master.dbo.sp_dropserver @server=N'FARRMS.MAIN', @droplogins='droplogins'
GO


EXEC sp_addlinkedserver   
   @server='FARRMS.MAIN',	--TODO: change
   @srvproduct='',
   @provider='SQLNCLI', 
   @datasrc=@server_name	--TODO: change
GO

EXEC sp_addlinkedsrvlogin 'FARRMS.MAIN', 'false', NULL, @user_name, @password
GO


EXEC sp_serveroption @server='FARRMS.MAIN', @optname='rpc', @optvalue='true'
EXEC sp_serveroption @server='FARRMS.MAIN', @optname='rpc out', @optvalue='true'