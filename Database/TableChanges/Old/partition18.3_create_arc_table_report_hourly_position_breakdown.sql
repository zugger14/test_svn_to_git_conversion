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
