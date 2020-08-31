SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
if OBJECT_ID('[report_hourly_position_breakdown_main]') is null
begin
CREATE TABLE [dbo].[report_hourly_position_breakdown_main](
/**
	Financial position breakdown of formula(contract) side.

	Columns
	source_deal_header_id : Deal ID foreign key to source_deal_header 
	curve_id : Financial curve ID
	term_start : Term start
	deal_date : Deal date
	deal_volume_uom_id : UOM ID
	create_ts : Create timestamp
	create_user : Create user
	calc_volume : Total financial position
	term_end : Term end
	expiration_date : Expiration date
	formula : Formula contract side
	source_deal_detail_id : Deal detail ID foreign key to source_deal_detail
	rowid : Filter group ID foreign Key to position_report_group_map
*/
	[source_deal_header_id] [int] NOT NULL,
	[curve_id] [int] NOT NULL,
	[term_start] [date] NOT NULL,
	[deal_date] [date] NOT NULL,
	[deal_volume_uom_id] [int] NOT NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](30) NULL,
	[calc_volume] [numeric](38, 20) NULL,
	[term_end] [datetime] NULL,
	[expiration_date] [date] NULL,
	[formula] [varchar](100) NULL,
	[source_deal_detail_id] [int] NOT NULL,
	[rowid] [int] NOT NULL
	, CONSTRAINT PKC_report_hourly_position_breakdown_main PRIMARY KEY CLUSTERED (term_start,source_deal_detail_id,curve_id)
	-- As we maintain delta position of the deal for explain position
	--, CONSTRAINT FK_report_hourly_position_breakdown_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE
	--, CONSTRAINT FK_report_hourly_position_breakdown_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id)  ON DELETE CASCADE
	, INDEX indx_report_hourly_position_breakdown_main_001 ([rowid])
	, INDEX indx_report_hourly_position_breakdown_main_002 ([source_deal_header_id])

) ON [PRIMARY]

END
ELSE
BEGIN
    PRINT 'Table [report_hourly_position_breakdown_main] EXISTS'
END

