IF OBJECT_ID('[dbo].[ice_deal_interface_staging]') IS NULL
BEGIN
	CREATE TABLE [dbo].[ice_deal_interface_staging](
		[id] [int] IDENTITY(1,1) NOT NULL,
		trade_date VARCHAR(200),
		trade_time VARCHAR(200),
		deal_id VARCHAR(200),
		leg VARCHAR(200),
		orig_id VARCHAR(200),
		buy_sell_flag VARCHAR(200),
		product VARCHAR(200),
		hub VARCHAR(200),
		Strip VARCHAR(200),
		term_start VARCHAR(200),
		term_end VARCHAR(200),
		option_price VARCHAR(200),
		strike_price VARCHAR(200),
		strike2_price VARCHAR(200),
		style VARCHAR(200),
		counterparty VARCHAR(200),
		price VARCHAR(200),
		price_unit VARCHAR(200),
		volume VARCHAR(200),
		periods VARCHAR(200),
		total_volume VARCHAR(200),
		volume_uom VARCHAR(200),
		trader VARCHAR(200),
		memo VARCHAR(200),
		clearing_venue VARCHAR(200),
		[user_id] VARCHAR(200),
		[source] VARCHAR(200),
		[usi] VARCHAR(200),
		[authorized_trader_id] VARCHAR(200),
		pipeline VARCHAR(200),
		[state] VARCHAR(200),
		[deal_status] VARCHAR(200),
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE()
	)
END
ELSE
    PRINT 'Table ice_deal_interface_staging Already Exists' 

