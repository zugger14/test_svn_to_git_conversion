IF OBJECT_ID('explain_position') IS  NULL
CREATE TABLE explain_position(
		[as_of_date_from] [datetime] NULL,
		[as_of_date_to] [datetime] NULL,
		[source_deal_header_id] [int] NULL,
		[curve_id] [int] NULL,
		[location_id] [int] NULL,
		commodity_id INT NULL,
		[term_start] [datetime] NULL,
		[expiration_date] DATETIME ,
		Hr TINYINT ,
		[ob_value] [numeric](18, 10) NULL,
		[new_deal] [numeric](18, 10) NULL,
		[modify_deal] [numeric](18, 10) NULL,
		[forecast_changed] [numeric](18, 10) NULL,
		[deleted] [numeric](18, 10) NULL,
		[delivered] [numeric](18, 10) NULL,
		[cb_value] [numeric](18, 10) NULL,
		create_ts_deal DATETIME,
		create_ts_position DATETIME
	)

	
IF OBJECT_ID('explain_position_detail') IS NOT   NULL
DROP TABLE explain_position_detail

IF OBJECT_ID('explain_position_header') IS NOT   NULL
DROP TABLE explain_position_header
	
	
	

	

