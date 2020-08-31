/****** Object:  Table [dbo].[report_hourly_position_deal]    Script Date: 02/24/2012 12:03:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stage_report_hourly_position_deal]', N'U') IS NULL

	CREATE TABLE [dbo].[stage_report_hourly_position_deal](
	[source_deal_header_id]			INT			NULL,
	[curve_id]						INT			NULL,
	[location_id]					INT			NULL,
	[term_start]					DATETIME	NOT NULL,
	[deal_date]						DATETIME	NULL,
	[commodity_id]					INT			NULL,
	[counterparty_id]				INT			NULL,
	[fas_book_id]					INT			NULL,
	[source_system_book_id1]		INT			NULL,
	[source_system_book_id2]		INT			NULL,
	[source_system_book_id3]		INT			NULL,
	[source_system_book_id4]		INT			NULL,
	[deal_volume_uom_id]			INT			NULL,
	[physical_financial_flag]		VARCHAR(1)	NULL,
	[hr1]							NUMERIC(38, 20) NULL,
	[hr2]							NUMERIC(38, 20) NULL,
	[hr3]							NUMERIC(38, 20) NULL,
	[hr4]							NUMERIC(38, 20) NULL,
	[hr5]							NUMERIC(38, 20) NULL,
	[hr6]							NUMERIC(38, 20) NULL,
	[hr7]							NUMERIC(38, 20) NULL,
	[hr8]							NUMERIC(38, 20) NULL,
	[hr9]							NUMERIC(38, 20) NULL,
	[hr10]							NUMERIC(38, 20) NULL,
	[hr11]							NUMERIC(38, 20) NULL,
	[hr12]							NUMERIC(38, 20) NULL,
	[hr13]							NUMERIC(38, 20) NULL,
	[hr14]							NUMERIC(38, 20) NULL,
	[hr15]							NUMERIC(38, 20) NULL,
	[hr16]							NUMERIC(38, 20) NULL,
	[hr17]							NUMERIC(38, 20) NULL,
	[hr18]							NUMERIC(38, 20) NULL,
	[hr19]							NUMERIC(38, 20) NULL,
	[hr20]							NUMERIC(38, 20) NULL,
	[hr21]							NUMERIC(38, 20) NULL,
	[hr22]							NUMERIC(38, 20) NULL,
	[hr23]							NUMERIC(38, 20) NULL,
	[hr24]							NUMERIC(38, 20) NULL,
	[hr25]							NUMERIC(38, 20) NULL,
	[create_ts]						DATETIME		NULL,
	[create_usr]					VARCHAR(30)		NULL,
	[expiration_date]				DATETIME		NULL,
	[deal_status_id]				INT				NULL
) ON PS_position_report_hourly_position_deal(term_start)

GO

SET ANSI_PADDING OFF
GO

/****** Object:  Index [indx_report_hourly_position_deal_deal_id]    Script Date: 02/24/2012 12:03:42 ******/
CREATE UNIQUE NONCLUSTERED INDEX [indx_report_hourly_position_deal_deal_id_stage] ON [dbo].[stage_report_hourly_position_deal] 
(
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position_report_hourly_position_deal(term_start)
GO


-----------------------------report_hourly_position_profile


IF OBJECT_ID(N'[dbo].[stage_report_hourly_position_profile]', N'U') IS NULL

CREATE TABLE [dbo].[stage_report_hourly_position_profile](
	[partition_value]				INT  NOT NULL,
	[source_deal_header_id]			int  NULL,
	[curve_id]						INT  NULL,
	[location_id]					INT  NULL,
	[term_start]					DATETIME  NOT NULL,
	[deal_date]						DATETIME  NULL,
	[commodity_id]					INT  NULL,
	[counterparty_id]				INT  NULL,
	[fas_book_id]					INT  NULL,
	[source_system_book_id1]		INT  NULL,
	[source_system_book_id2]		INT  NULL,
	[source_system_book_id3]		INT  NULL,
	[source_system_book_id4]		INT  NULL,
	[deal_volume_uom_id]			INT  NULL,
	[physical_financial_flag]		VARCHAR(1) NULL,
	[hr1]							NUMERIC(38, 20) NULL,
	[hr2]							NUMERIC(38, 20) NULL,
	[hr3]							NUMERIC(38, 20) NULL,
	[hr4]							NUMERIC(38, 20) NULL,
	[hr5]							NUMERIC(38, 20) NULL,
	[hr6]							NUMERIC(38, 20) NULL,
	[hr7]							NUMERIC(38, 20) NULL,
	[hr8]							NUMERIC(38, 20) NULL,
	[hr9]							NUMERIC(38, 20) NULL,
	[hr10]							NUMERIC(38, 20) NULL,
	[hr11]							NUMERIC(38, 20) NULL,
	[hr12]							NUMERIC(38, 20) NULL,
	[hr13]							NUMERIC(38, 20) NULL,
	[hr14]							NUMERIC(38, 20) NULL,
	[hr15]							NUMERIC(38, 20) NULL,
	[hr16]							NUMERIC(38, 20) NULL,
	[hr17]							NUMERIC(38, 20) NULL,
	[hr18]							NUMERIC(38, 20) NULL,
	[hr19]							NUMERIC(38, 20) NULL,
	[hr20]							NUMERIC(38, 20) NULL,
	[hr21]							NUMERIC(38, 20) NULL,
	[hr22]							NUMERIC(38, 20) NULL,
	[hr23]							NUMERIC(38, 20) NULL,
	[hr24]							NUMERIC(38, 20) NULL,
	[hr25]							NUMERIC(38, 20) NULL,
	[create_ts]						DATETIME NULL,
	[create_usr]					VARCHAR(30) NULL,
	[expiration_date]				DATETIME NULL,
	[deal_status_id]				INT NULL
)	ON PS_position_report_hourly_position_profile(term_start)

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_report_hourly_position_profile]    Script Date: 02/28/2012 10:18:07 ******/
CREATE CLUSTERED INDEX [indx_report_hourly_position_profile_stage] ON [dbo].[stage_report_hourly_position_profile] 
(
	[term_start] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position_report_hourly_position_profile(term_start)
GO


/****** Object:  Index [indx_report_hourly_position_profile_deal_id]    Script Date: 02/28/2012 10:18:07 ******/
CREATE UNIQUE NONCLUSTERED INDEX [indx_report_hourly_position_profile_deal_id_stage] ON [dbo].[stage_report_hourly_position_profile] 
(
	[partition_value] ASC,
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position_report_hourly_position_profile(term_start)
GO

ALTER TABLE [dbo].[stage_report_hourly_position_profile] SET (LOCK_ESCALATION = AUTO)
GO


-----------------------------report_hourly_position_breakdown

/****** Object:  Table [dbo].[report_hourly_position_breakdown ]    Script Date: 02/28/2012 14:10:49 ******/
IF OBJECT_ID(N'[dbo].[stage_report_hourly_position_breakdown]', N'U') IS NULL

/****** Object:  Table [dbo].[report_hourly_position_breakdown ]    Script Date: 02/28/2012 14:10:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[stage_report_hourly_position_breakdown](
	[source_deal_header_id]			[int] NULL,
	[curve_id]						[int] NULL,
	[location_id]					[int] NULL,
	[term_start]					[datetime] NOT NULL,
	[deal_date]						[datetime] NULL,
	[commodity_id]					[int] NULL,
	[counterparty_id]				[int] NULL,
	[fas_book_id]					[int] NULL,
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
) ON ps_position_report_hourly_position_breakdown(term_start)

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_report_hourly_position_breakdown_commodity_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_commodity_id_stage] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[commodity_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)ON ps_position_report_hourly_position_breakdown(term_start)

GO


/****** Object:  Index [indx_report_hourly_position_breakdown_counterparty_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_counterparty_id_stage] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[counterparty_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)ON ps_position_report_hourly_position_breakdown(term_start)

GO


/****** Object:  Index [indx_report_hourly_position_breakdown_deal_date]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_deal_date_stage] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[deal_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_position_report_hourly_position_breakdown(term_start)

GO


/****** Object:  Index [indx_report_hourly_position_breakdown_fas_book_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_fas_book_id_stage] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[fas_book_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_position_report_hourly_position_breakdown(term_start)
GO


/****** Object:  Index [indx_report_hourly_position_breakdown_source_system_book_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_source_system_book_id_stage] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[source_system_book_id1] ASC,
	[source_system_book_id2] ASC,
	[source_system_book_id3] ASC,
	[source_system_book_id4] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_position_report_hourly_position_breakdown(term_start)
GO


/****** Object:  Index [indx_report_hourly_position_breakdown_volume_uom_id]    Script Date: 02/28/2012 14:10:49 ******/
CREATE NONCLUSTERED INDEX [indx_report_hourly_position_breakdown_volume_uom_id_stage] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[deal_volume_uom_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON ps_position_report_hourly_position_breakdown(term_start)
GO


/****** Object:  Index [unique_indx_report_hourly_position_breakdown]    Script Date: 02/28/2012 14:10:49 ******/
CREATE UNIQUE NONCLUSTERED INDEX [unique_indx_report_hourly_position_breakdown_stage] ON [dbo].[stage_report_hourly_position_breakdown ] 
(
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[term_start] ASC,
	[term_end] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON  ps_position_report_hourly_position_breakdown(term_start)
GO


-----------------------------delta_report_hourly_position

IF OBJECT_ID(N'[dbo].[stage_delta_report_hourly_position]', N'U') IS NULL

/****** Object:  Table [dbo].[delta_report_hourly_position]    Script Date: 02/28/2012 15:38:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[stage_delta_report_hourly_position](
	[as_of_date] [datetime] NULL,
	[partition_value] [int] NULL,
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NOT NULL,
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
) ON PS_position_delta_report_hourly_position(term_start)

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_delta_report_hourly_position_as_of_date]    Script Date: 02/28/2012 15:38:28 ******/
CREATE NONCLUSTERED INDEX [indx_delta_report_hourly_position_as_of_date_stage] ON [dbo].[stage_delta_report_hourly_position] 
(
	[as_of_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)ON PS_position_delta_report_hourly_position(term_start)
GO


/****** Object:  Index [indx_delta_report_hourly_position_delta_type]    Script Date: 02/28/2012 15:38:28 ******/
CREATE NONCLUSTERED INDEX [indx_delta_report_hourly_position_delta_type_stage] ON [dbo].[stage_delta_report_hourly_position] 
(
	[delta_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position_delta_report_hourly_position(term_start)
GO


/****** Object:  Index [indx_delta_report_hourly_position_id]    Script Date: 02/28/2012 15:38:28 ******/
CREATE NONCLUSTERED INDEX [indx_delta_report_hourly_position_id_stage] ON [dbo].[stage_delta_report_hourly_position] 
(
	[source_deal_header_id] ASC,
	[curve_id] ASC,
	[location_id] ASC,
	[term_start] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON PS_position_delta_report_hourly_position(term_start)
GO






-----------------------------report_hourly_position_fixed


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stage_report_hourly_position_fixed]') AND type IN (N'U'))

CREATE TABLE [dbo].[stage_report_hourly_position_fixed](
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NOT NULL,
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
	[hr1] [float] NULL,
	[hr2] [float] NULL,
	[hr3] [float] NULL,
	[hr4] [float] NULL,
	[hr5] [float] NULL,
	[hr6] [float] NULL,
	[hr7] [float] NULL,
	[hr8] [float] NULL,
	[hr9] [float] NULL,
	[hr10] [float] NULL,
	[hr11] [float] NULL,
	[hr12] [float] NULL,
	[hr13] [float] NULL,
	[hr14] [float] NULL,
	[hr15] [float] NULL,
	[hr16] [float] NULL,
	[hr17] [float] NULL,
	[hr18] [float] NULL,
	[hr19] [float] NULL,
	[hr20] [float] NULL,
	[hr21] [float] NULL,
	[hr22] [float] NULL,
	[hr23] [float] NULL,
	[hr24] [float] NULL,
	[hr25] [float] NULL,
	[create_ts] [datetime] NULL,
	[create_usr] [varchar](30) NULL,
	[expiration_date] [datetime] NULL,
	[deal_status] [int] NULL
) ON  ps_position_report_hourly_position_fixed(term_start)

GO

SET ANSI_PADDING OFF
GO




-----------------------------report_hourly_position_fixed



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stage_deal_position_break_down]') AND type IN (N'U'))

CREATE TABLE [dbo].[stage_deal_position_break_down](
	[breakdown_id] [int] IDENTITY(1,1) NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[source_deal_detail_id] [int] NOT NULL,
	[leg] [int] NOT NULL,
	[strip_from] [tinyint] NULL,
	[lag] [tinyint] NULL,
	[strip_to] [tinyint] NULL,
	[curve_id] [int] NOT NULL,
	[prior_year] [smallint] NULL,
	[multiplier] [float] NOT NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](50) NULL,
	[derived_curve_id] [int] NULL,
	[location_id] [int] NULL,
	[volume_uom_id] [int] NULL,
	[commodity_id] [int] NULL,
	[phy_fin_flag] [varchar](1) NULL,
	[del_term_start] [datetime] NULL,
	[fin_term_start] [datetime] NULL,
	[fin_expiration_date] [datetime] NULL,
	[del_vol_multiplier] [float] NULL,
	[fin_term_end] [datetime] NULL,
	[formula] [varchar](100) NULL
) ON ps_position_deal_position_break_down(del_term_start)

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[stage_deal_position_break_down]  WITH NOCHECK ADD  CONSTRAINT [FK_deal_position_break_down_source_deal_header1_stage] FOREIGN KEY([source_deal_header_id])
REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])
GO

ALTER TABLE [dbo].[stage_deal_position_break_down] CHECK CONSTRAINT [FK_deal_position_break_down_source_deal_header1_stage]
GO

ALTER TABLE [dbo].[stage_deal_position_break_down]  WITH NOCHECK ADD  CONSTRAINT [FK_deal_position_break_down_source_price_curve_def1_stage] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO

ALTER TABLE [dbo].[stage_deal_position_break_down] CHECK CONSTRAINT [FK_deal_position_break_down_source_price_curve_def1_stage]
GO


-----------------------------report_hourly_position_fixed


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stage_delta_report_hourly_position_breakdown]') AND type IN (N'U'))

CREATE TABLE [dbo].[stage_delta_report_hourly_position_breakdown](
	[as_of_date] [datetime] NULL,
	[source_deal_header_id] [int] NULL,
	[curve_id] [int] NULL,
	[location_id] [int] NULL,
	[term_start] [datetime] NOT NULL,
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
	[delta_type] [int] NULL,
	[expiration_date] [datetime] NULL,
	[term_end] [datetime] NULL,
	[deal_status_id] [int] NULL,
	[formula] [varchar](100) NULL
) ON ps_position_delta_report_hourly_position_breakdown(term_start)


GO

SET ANSI_PADDING OFF
GO


