SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go

if OBJECT_ID('[report_hourly_position_financial_main]') is null
begin
CREATE TABLE [dbo].[report_hourly_position_financial_main](
/**
	Financial position breakdown of physical allocation position.

	Columns
	source_deal_header_id : Deal ID foreign key to source_deal_header 
	term_start : Term start
	deal_date : Deal date
	deal_volume_uom_id : UOM ID
	hr1 : Hour 1 Position
	hr2 : Hour 2 Position
	hr3 : Hour 3 Position
	hr4 : Hour 4 Position
	hr5 : Hour 5 Position
	hr6 : Hour 6 Position
	hr7 : Hour 7 Position
	hr8 : Hour 8 Position
	hr9 : Hour 9 Position
	hr10 : Hour 10 Position
	hr11 : Hour 11 Position
	hr12 : Hour 12 Position
	hr13 : Hour 13 Position
	hr14 : Hour 14 Position
	hr15 : Hour 15 Position
	hr16 : Hour 16 Position
	hr17 : Hour 17 Position
	hr18 : Hour 18 Position
	hr19 : Hour 19 Position
	hr20 : Hour 20 Position
	hr21 : Hour 21 Position
	hr22 : Hour 22 Position
	hr23 : Hour 23 Position
	hr24 : Hour 24 Position
	hr25 : Hour 25 Position
	create_ts : Create timestamp
	create_user : Create user
	expiration_date : Expiration date
	period : Period
	granularity : Granularity position breakdown
	source_deal_detail_id : Deal detail ID foreign key to source_deal_detail
	rowid : Filter group ID foreign Key to position_report_group_map


*/	
	[source_deal_header_id] [int] NOT NULL,
	[term_start] [date] NOT NULL,
	[deal_date] [date] NOT NULL,
	[deal_volume_uom_id] [int] NOT NULL,
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
	[create_user] [varchar](30) NULL,
	expiration_date [date] NULL,
	[granularity] [int] NOT NULL,
	[period] [tinyint] NOT NULL DEFAULT 0,
	[source_deal_detail_id] [int] NOT NULL,
	[rowid] [int] NOT NULL
	, CONSTRAINT PKC_report_hourly_position_financial_main PRIMARY KEY CLUSTERED (term_start,source_deal_detail_id,[period])
	-- As we maintain delta position of the deal for explain position
	--, CONSTRAINT FK_report_hourly_position_financial_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id) ON DELETE CASCADE
	--, CONSTRAINT FK_report_hourly_position_financial_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id) ON DELETE CASCADE
	, INDEX indx_report_hourly_position_financial_main_001 ([rowid])
	, INDEX indx_report_hourly_position_financial_main_002 ([source_deal_header_id])

) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table [report_hourly_position_financial_main] EXISTS'
END


