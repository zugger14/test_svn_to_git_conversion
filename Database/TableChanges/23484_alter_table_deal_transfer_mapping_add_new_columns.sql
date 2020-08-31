IF OBJECT_ID(N'[dbo].[deal_transfer_mapping]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[deal_transfer_mapping]', 'pricing_type') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        pricing_type : pricing_type
    */
	deal_transfer_mapping ADD pricing_type INT NULL
END

IF OBJECT_ID(N'[dbo].[deal_transfer_mapping]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[deal_transfer_mapping]', 'commodity_id') IS NULL
BEGIN
	ALTER TABLE
	 /**
        Columns
        commodity_id : commodity_id
    */
	deal_transfer_mapping ADD commodity_id INT NULL
END


IF OBJECT_ID(N'[dbo].[deal_transfer_mapping]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[deal_transfer_mapping]', 'internal_portfolio_id') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        internal_portfolio_id : internal_portfolio_id
    */
	deal_transfer_mapping ADD internal_portfolio_id INT NULL
END
