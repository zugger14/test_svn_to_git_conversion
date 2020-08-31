/****** Object:  Table [dbo].[report_hourly_position_deal]    Script Date: 02/24/2012 12:03:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'[dbo].[report_hourly_position_deal_arch1]', N'U') IS NULL

	CREATE TABLE [dbo].[report_hourly_position_deal_arch1](
	[source_deal_header_id]			INT			NULL,
	[curve_id]						INT			NULL,
	[location_id]					INT			NULL,
	[term_start]					DATETIME	NULL,
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
) 

GO

SET ANSI_PADDING OFF
GO
IF OBJECT_ID(N'[dbo].[report_hourly_position_deal_arch2]', N'U') IS NULL

	CREATE TABLE [dbo].[report_hourly_position_deal_arch2](
	[source_deal_header_id]			INT			NULL,
	[curve_id]						INT			NULL,
	[location_id]					INT			NULL,
	[term_start]					DATETIME	NULL,
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
) 

GO

SET ANSI_PADDING OFF
GO


-----------------------------report_hourly_position_profile


IF OBJECT_ID(N'[dbo].[report_hourly_position_profile_arch1]', N'U') IS NULL

CREATE TABLE [dbo].[report_hourly_position_profile_arch1](
	[partition_value]				INT  NOT NULL,
	[source_deal_header_id]			int  NULL,
	[curve_id]						INT  NULL,
	[location_id]					INT  NULL,
	[term_start]					DATETIME  NULL,
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
)	

GO

SET ANSI_PADDING OFF
GO


IF OBJECT_ID(N'[dbo].[report_hourly_position_profile_arch2]', N'U') IS NULL

CREATE TABLE [dbo].[report_hourly_position_profile_arch2](
	[partition_value]				INT  NOT NULL,
	[source_deal_header_id]			int  NULL,
	[curve_id]						INT  NULL,
	[location_id]					INT  NULL,
	[term_start]					DATETIME  NULL,
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
)	

GO

SET ANSI_PADDING OFF
GO


-----------------------------report_hourly_position_breakdown



IF OBJECT_ID(N'[dbo].[report_hourly_position_breakdown_arch1]', N'U') IS NULL

/****** Object:  Table [dbo].[report_hourly_position_breakdown ]    Script Date: 02/28/2012 14:10:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[report_hourly_position_breakdown_arch1](
	[source_deal_header_id]			[int] NULL,
	[curve_id]						[int] NULL,
	[location_id]					[int] NULL,
	[term_start]					[datetime] NULL,
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
) 

GO

SET ANSI_PADDING OFF
GO

IF OBJECT_ID(N'[dbo].[report_hourly_position_breakdown_arch2]', N'U') IS NULL

/****** Object:  Table [dbo].[report_hourly_position_breakdown ]    Script Date: 02/28/2012 14:10:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[report_hourly_position_breakdown_arch2](
	[source_deal_header_id]			[int] NULL,
	[curve_id]						[int] NULL,
	[location_id]					[int] NULL,
	[term_start]					[datetime] NULL,
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
) 

GO

SET ANSI_PADDING OFF
GO


-----------------------------delta_report_hourly_position


IF OBJECT_ID(N'[dbo].[delta_report_hourly_position_arch1]', N'U') IS NULL
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

IF OBJECT_ID(N'[dbo].[delta_report_hourly_position_arch2]', N'U') IS NULL
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



-----------------------------report_hourly_position_fixed


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_fixed_arch1]') AND type IN (N'U'))

CREATE TABLE [dbo].[report_hourly_position_fixed_arch1](
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
)

GO

SET ANSI_PADDING OFF
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[report_hourly_position_fixed_arch2]') AND type IN (N'U'))

CREATE TABLE [dbo].[report_hourly_position_fixed_arch2](
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
)

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
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_position_break_down_arch1]') AND type IN (N'U'))

CREATE TABLE [dbo].[deal_position_break_down_arch1](
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
	[formula] [varchar](100) NULL,
 CONSTRAINT [PK_deal_position_break_down1] PRIMARY KEY NONCLUSTERED 
(
	[breakdown_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)  ON [PRIMARY]
) 

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[deal_position_break_down_arch1]  WITH NOCHECK ADD  CONSTRAINT [FK_deal_position_break_down_source_deal_header1] FOREIGN KEY([source_deal_header_id])
REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])
GO

ALTER TABLE [dbo].[deal_position_break_down_arch1] CHECK CONSTRAINT [FK_deal_position_break_down_source_deal_header1]
GO

ALTER TABLE [dbo].[deal_position_break_down_arch1]  WITH NOCHECK ADD  CONSTRAINT [FK_deal_position_break_down_source_price_curve_def1] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO

ALTER TABLE [dbo].[deal_position_break_down_arch1] CHECK CONSTRAINT [FK_deal_position_break_down_source_price_curve_def1]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[deal_position_break_down_arch2]') AND type IN (N'U'))

CREATE TABLE [dbo].[deal_position_break_down_arch2](
	[breakdown_id] [int]  NOT NULL,
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
	[formula] [varchar](100) NULL,
 CONSTRAINT [PK_deal_position_break_down1_arch1] PRIMARY KEY NONCLUSTERED 
(
	[breakdown_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90)  ON [PRIMARY]
) 

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[deal_position_break_down_arch2]  WITH NOCHECK ADD  CONSTRAINT [FK_deal_position_break_down_source_deal_header1_arch2] FOREIGN KEY([source_deal_header_id])
REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])
GO

ALTER TABLE [dbo].[deal_position_break_down_arch2] CHECK CONSTRAINT [FK_deal_position_break_down_source_deal_header1]
GO

ALTER TABLE [dbo].[deal_position_break_down_arch2]  WITH NOCHECK ADD  CONSTRAINT [FK_deal_position_break_down_source_price_curve_def1_arch2] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO

ALTER TABLE [dbo].[deal_position_break_down_arch2] CHECK CONSTRAINT [FK_deal_position_break_down_source_price_curve_def1_arch2]
GO
-----------------------------report_hourly_position_fixed

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[delta_report_hourly_position_breakdown_arch1]') AND type IN (N'U'))

CREATE TABLE [dbo].[delta_report_hourly_position_breakdown_arch1](
	[as_of_date] [datetime] NULL,
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
	[delta_type] [int] NULL,
	[expiration_date] [datetime] NULL,
	[term_end] [datetime] NULL,
	[deal_status_id] [int] NULL,
	[formula] [varchar](100) NULL
)


GO

SET ANSI_PADDING OFF
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[delta_report_hourly_position_breakdown_arch2]') AND type IN (N'U'))

CREATE TABLE [dbo].[delta_report_hourly_position_breakdown_arch2](
	[as_of_date] [datetime] NULL,
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
	[delta_type] [int] NULL,
	[expiration_date] [datetime] NULL,
	[term_end] [datetime] NULL,
	[deal_status_id] [int] NULL,
	[formula] [varchar](100) NULL
)


GO

SET ANSI_PADDING OFF
GO
