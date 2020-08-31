IF OBJECT_ID(N'[dbo].[counterparty_credit_info_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_info_audit]', 'analyst') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        analyst : analyst
    */
	counterparty_credit_info_audit ADD analyst NVARCHAR(200) NULL
END

IF OBJECT_ID(N'[dbo].[counterparty_credit_info_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_info_audit]', 'rating_outlook') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        rating_outlook : rating_outlook
    */
	counterparty_credit_info_audit ADD rating_outlook INT NULL
END

IF OBJECT_ID(N'[dbo].[counterparty_credit_info_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_info_audit]', 'formula') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        formula : formula
    */
	counterparty_credit_info_audit ADD formula INT NULL
END

IF OBJECT_ID(N'[dbo].[counterparty_credit_info_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_info_audit]', 'qualitative_rating') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        qualitative_rating : qualitative_rating
    */
	counterparty_credit_info_audit ADD qualitative_rating INT NULL
END

IF OBJECT_ID(N'[dbo].[counterparty_credit_info_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_info_audit]', 'buy_notional_month') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        buy_notional_month : buy_notional_month
    */
	counterparty_credit_info_audit ADD  buy_notional_month NUMERIC(38,20)NULL
END

IF OBJECT_ID(N'[dbo].[counterparty_credit_info_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_info_audit]', 'sell_notional_month') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        sell_notional_month : sell_notional_month
    */
	counterparty_credit_info_audit ADD sell_notional_month NUMERIC(38,20)NULL
END

IF OBJECT_ID(N'[dbo].[counterparty_credit_info_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_info_audit]', 'user_action') IS NOT NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        analyst : analyst
    */
	counterparty_credit_info_audit ALTER COLUMN user_action VARCHAR(15)
END