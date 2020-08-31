IF OBJECT_ID(N'[dbo].[counterparty_credit_limits_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_limits_audit]', 'threshold_provided') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        threshold_provided : threshold_provided
    */
	counterparty_credit_limits_audit ADD threshold_provided FLOAT NULL
END

IF OBJECT_ID(N'[dbo].[counterparty_credit_limits_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_limits_audit]', 'threshold_received') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        threshold_received : threshold_received
    */
	counterparty_credit_limits_audit ADD threshold_received FLOAT NULL
END

IF OBJECT_ID(N'[dbo].[counterparty_credit_limits_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_limits_audit]', 'limit_status') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        limit_status : limit_status
    */
	counterparty_credit_limits_audit ADD limit_status INT NULL
END


IF OBJECT_ID(N'[dbo].[counterparty_credit_limits_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[counterparty_credit_limits_audit]', 'user_action') IS NOT NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        analyst : analyst
    */
	counterparty_credit_limits_audit ALTER COLUMN user_action VARCHAR(15)
END