SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[split_deal_actuals]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].split_deal_actuals (
		[split_deal_actuals_id] INT IDENTITY(1, 1) NOT NULL,
		--source_deal_detail_id INT,
		ticket_number VARCHAR(1000),
		schedule_match_id INT,
		ticket_issuer INT,
		term_start DATETIME,
		term_end DATETIME,
		date_issued	DATETIME,
		carrier	INT,		
		vehicle_number VARCHAR(1000),
		movement_date_time DATETIME,
		movement_location INT,
		origin  VARCHAR(1000),
		destination	VARCHAR(1000),
		product_commodity INT,
		net_volume NUMERIC(38,18),
		uom	INT,
		temperature	FLOAT,
		temp_scale_f_c CHAR(1),
		api_gravity FLOAT,	
		specific_gravity FLOAT,
		line_item INT,
		automatch_status CHAR(1),
		buy_deal_id INT,
		sell_deal_id INT,
		location_id INT,
		shipper INT,
		consginee INT,
		ticket_type INT,
		container_id INT,
		ticket_matching_no INT,
		density FLOAT,
		density_uom INT,
		volume_uom INT,	
		weight_uom INT,
		gross_volume INT,
		gross_weight INT,
		net_weight INT,
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table split_deal_actuals EXISTS'
END
 
GO