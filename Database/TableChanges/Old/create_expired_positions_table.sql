if not exists(select 1 from sys.columns where name='term_end' and [object_id]=object_id('delta_report_hourly_position_breakdown'))
alter table delta_report_hourly_position_breakdown add term_end datetime
go


IF object_id('expired_report_hourly_position_profile') IS NOT NULL
DROP TABLE expired_report_hourly_position_profile
GO

CREATE TABLE [dbo].[expired_report_hourly_position_profile](
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
	[expiration_date] [datetime] NULL
)

GO


/****** Object:  Index [indx_report_hourly_position_profile_deal_id]    Script Date: 06/17/2011 09:43:53 ******/
CREATE NONCLUSTERED INDEX [indx_expired_report_hourly_position_profile_deal_id] ON [dbo].[expired_report_hourly_position_profile] 
(
	[source_deal_header_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)

GO

IF object_id('expired_report_hourly_position_deal') IS NOT NULL
DROP TABLE expired_report_hourly_position_deal

GO

CREATE TABLE [dbo].[expired_report_hourly_position_deal](
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
	[expiration_date] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


/****** Object:  Index [indx_report_hourly_position_deal_deal_id]    Script Date: 06/17/2011 09:43:42 ******/
CREATE NONCLUSTERED INDEX [indx_expired_report_hourly_position_deal_deal_id] ON [dbo].[expired_report_hourly_position_deal] 
(
	[source_deal_header_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


IF object_id('expired_report_hourly_position_breakdown') IS NOT NULL
DROP TABLE expired_report_hourly_position_breakdown
GO


CREATE TABLE [dbo].[expired_report_hourly_position_breakdown](
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
	[calc_volume] [float] NULL,
	[term_end] [datetime] NULL,
	[expiration_date] [datetime] NULL
) ON [PRIMARY]

GO
