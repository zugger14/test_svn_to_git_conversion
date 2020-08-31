/****** Object:  Table [dbo].[delta_report_hourly_position]    Script Date: 02/28/2012 15:38:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[delta_report_hourly_position]') AND type in (N'U'))
DROP TABLE [dbo].[delta_report_hourly_position]
GO

/****** Object:  Table [dbo].[delta_report_hourly_position]    Script Date: 02/28/2012 15:38:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

SP_RENAME delta_report_hourly_position , delta_report_hourly_position_non_part

CREATE TABLE [dbo].[delta_report_hourly_position](
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
) ON PS_position(term_start)

GO

INSERT INTO delta_report_hourly_position SELECT * FROM delta_report_hourly_position_non_part 

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_delta_report_hourly_position_as_of_date]    Script Date: 02/28/2012 15:38:28 ******/
CREATE NONCLUSTERED INDEX [indx_delta_report_hourly_position_as_of_date] ON [dbo].[delta_report_hourly_position] 
(
	[as_of_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)ON PS_position(term_start)
GO


/****** Object:  Index [indx_delta_report_hourly_position_delta_type]    Script Date: 02/28/2012 15:38:28 ******/
CREATE NONCLUSTERED INDEX [indx_delta_report_hourly_position_delta_type] ON [dbo].[delta_report_hourly_position] 
(
	[delta_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position(term_start)
GO


/****** Object:  Index [indx_delta_report_hourly_position_id]    Script Date: 02/28/2012 15:38:28 ******/
CREATE NONCLUSTERED INDEX [indx_delta_report_hourly_position_id] ON [dbo].[delta_report_hourly_position] 
(
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position(term_start)
GO


