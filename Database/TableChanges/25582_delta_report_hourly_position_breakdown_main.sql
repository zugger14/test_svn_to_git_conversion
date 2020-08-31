SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go

if OBJECT_ID('[delta_report_hourly_position_breakdown_main]') is null
begin
CREATE TABLE [dbo].[delta_report_hourly_position_breakdown_main](
/**
	Delta of financial position breakdown

	Columns
	as_of_date : Date of data changed
	source_deal_header_id : Deal ID foreign key to source_deal_header 
	curve_id : Financial curve ID
	term_start : Financial term start
	deal_date : Deal Date
	deal_volume_uom_id : UOM ID 
	calc_volume : Financial position
	create_ts : Record insert timestamp
	create_user : Record insert user
	delta_type : Delta type
	expiration_date : Expiration date
	term_end : Financial term end
	formula : Formula contract side
	source_deal_detail_id : Deal detail ID foreign key to source_deal_detail
	rowid : Filter group ID foreign Key to position_report_group_map
*/
	[as_of_date] [datetime] NOT NULL,
	[source_deal_header_id] [int] NOT NULL,
	[curve_id] [int] NOT NULL,
	[term_start] [date] NOT NULL,
	[deal_date] [date] NOT NULL,
	[deal_volume_uom_id] [int] NOT NULL,
	[calc_volume] [numeric](38, 20) NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](30) NULL,
	[delta_type] [int] NOT NULL,
	[expiration_date] [date] NULL,
	[term_end] [datetime] NULL,
	[formula] [varchar](100) NULL,
	[source_deal_detail_id] [int] NOT NULL,
	[rowid] [int] NOT NULL
	, CONSTRAINT PKC_delta_report_hourly_position_breakdown_main PRIMARY KEY CLUSTERED (term_start,source_deal_detail_id,curve_id,delta_type,as_of_date)
	-- As we maintain delta position of the deal for explain position
	--, CONSTRAINT FK_delta_report_hourly_position_breakdown_main_001 FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id) ON DELETE CASCADE
	--, CONSTRAINT FK_delta_report_hourly_position_breakdown_main_002 FOREIGN KEY (source_deal_header_id) REFERENCES dbo.source_deal_header(source_deal_header_id) ON DELETE CASCADE
	, INDEX indx_report_hourly_position_breakdown_main_001 ([rowid])
	, INDEX indx_report_hourly_position_breakdown_main_002 ([source_deal_header_id])

) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table [delta_report_hourly_position_breakdown_main] EXISTS'
END

