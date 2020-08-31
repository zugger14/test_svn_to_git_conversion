SET ANSI_NULLS ON
go
SET QUOTED_IDENTIFIER ON
go
if OBJECT_ID('position_report_group_map') is null
begin

create table dbo.position_report_group_map (
/**
	Group mapping of filters for position report.

	Columns
	rowid : Identity column
	curve_id : Curve ID
	location_id : Location ID
	commodity_id : Commodity ID
	counterparty_id : Counterparty ID
	trader_id : Trader ID
	contract_id : Contract ID
	subbook_id : Sub book ID
	deal_status_id : Deal status ID
	deal_type : Deal type
	pricing_type : Pricing type
	internal_portfolio_id : Product group
	physical_financial_flag : Physical or Financial flag
	create_user : Record insert user
	create_ts : Record insert timestamp
*/
	rowid int identity(1,1)
	,curve_id int NOT null DEFAULT -1 -- deal curve_id
	,location_id int NOT null DEFAULT -1
	,commodity_id int NOT null DEFAULT -1
	,counterparty_id int NOT null DEFAULT -1
	,trader_id int NOT null DEFAULT -1
	,contract_id int NOT null DEFAULT -1
	,subbook_id int NOT null DEFAULT -1
	--,deal_volume_uom_id int -- financial curve from formula has different uom than physical curve uom, so the deal_volume_uom_id is put in position calculated table.
	,deal_status_id int NOT null DEFAULT -1
	,deal_type int  NOT null DEFAULT -1
	,pricing_type int NOT null DEFAULT -1
	,internal_portfolio_id int NOT null DEFAULT -1 --product_group
	,physical_financial_flag nchar(1) NOT null DEFAULT 'p',
	create_user VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	create_ts DATETIME NULL DEFAULT GETDATE()
	, CONSTRAINT PK_position_report_group_map PRIMARY KEY (rowid)
	, CONSTRAINT UC_position_report_group_map UNIQUE CLUSTERED (
		curve_id,location_id,commodity_id,counterparty_id,trader_id,contract_id,subbook_id,deal_status_id,deal_type ,pricing_type,internal_portfolio_id,physical_financial_flag)
)
END
ELSE
BEGIN
    PRINT 'Table position_report_group_map EXISTS'
END
