IF OBJECT_ID(N'[dbo].[deal_transfer_mapping]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[deal_transfer_mapping]', 'header_buy_sell_flag') IS NULL
BEGIN
	ALTER TABLE  
	/**
        Columns
        header_buy_sell_flag : header_buy_sell_flag
    */
	deal_transfer_mapping ADD header_buy_sell_flag nvarchar(2)
END

IF OBJECT_ID(N'[dbo].[deal_transfer_mapping]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[deal_transfer_mapping]', 'physical_financial_flag') IS NULL
BEGIN
	ALTER TABLE
	 /**
        Columns
        physical_financial_flag : physical_financial_flag
    */
	deal_transfer_mapping ADD physical_financial_flag nchar(20)
END
