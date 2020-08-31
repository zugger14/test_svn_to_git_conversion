SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
if OBJECT_ID('source_deal_detail_position') is null
begin
/**
	Store total volume of deal detail for the period of term

	Columns
	source_deal_detail_id : Foreign key to source_deal_detail
	total_volume : Total Volume
	hourly_position : Hourly Volume
	position_report_group_map_rowid : Foreign Key to position_report_group_map
	create_user : Record insert user
	create_ts : Record insert timestamp
*/
create table dbo.source_deal_detail_position (
	source_deal_detail_id int NOT null
	,total_volume numeric(38,10)
	,hourly_position numeric(24,10)
	,position_report_group_map_rowid int,
	create_user VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	create_ts DATETIME NULL DEFAULT GETDATE()
	, CONSTRAINT FK_source_deal_detail_id FOREIGN KEY (source_deal_detail_id) REFERENCES dbo.source_deal_detail(source_deal_detail_id)  ON DELETE CASCADE
	, CONSTRAINT PKC_source_deal_detail_position PRIMARY KEY CLUSTERED (source_deal_detail_id)
)
END
ELSE
BEGIN
    PRINT 'Table source_deal_detail_position EXISTS'
END



