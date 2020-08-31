/****** Object:  Table [dbo].[report_hourly_position_breakdown ]    Script Date: 02/28/2012 14:10:49 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stage_report_hourly_position_breakdown ]') AND type in (N'U'))
DROP TABLE [dbo].[stage_report_hourly_position_breakdown ]
GO

/****** Object:  Table [dbo].[stage_report_hourly_position_breakdown ]    Script Date: 02/28/2012 14:10:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[stage_report_hourly_position_breakdown ](
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
) ON PS_position(term_start)

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_report_hourly_position_breakdown_commodity_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_commodity_id] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[commodity_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)ON PS_position(term_start)

GO


/****** Object:  Index [indx_report_hourly_position_breakdown_counterparty_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_counterparty_id] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[counterparty_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)ON PS_position(term_start)

GO


/****** Object:  Index [indx_report_hourly_position_breakdown_deal_date]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_deal_date] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[deal_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position(term_start)

GO


/****** Object:  Index [indx_report_hourly_position_breakdown_fas_book_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_fas_book_id] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[fas_book_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position(term_start)
GO


/****** Object:  Index [indx_report_hourly_position_breakdown_source_system_book_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_source_system_book_id] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[source_system_book_id1] ASC,
	[source_system_book_id2] ASC,
	[source_system_book_id3] ASC,
	[source_system_book_id4] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position(term_start)
GO


/****** Object:  Index [indx_report_hourly_position_breakdown_volume_uom_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_volume_uom_id] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[deal_volume_uom_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position(term_start)
GO


/****** Object:  Index [unique_indx_report_hourly_position_breakdown]    Script Date: 02/28/2012 14:10:49 ******/
CREATE UNIQUE NONCLUSTERED INDEX [unique_indx_report_hourly_position_breakdown] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[term_start] ASC,
	[term_end] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON  PS_position(term_start)
GO


