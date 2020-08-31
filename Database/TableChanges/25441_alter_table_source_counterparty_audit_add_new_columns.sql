IF OBJECT_ID(N'[dbo].[source_counterparty_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[source_counterparty_audit]', 'counterparty_contact_notes') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        counterparty_contact_notes : counterparty_contact_notes
    */
	source_counterparty_audit ADD counterparty_contact_notes VARCHAR(200) NULL
END

IF OBJECT_ID(N'[dbo].[source_counterparty_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[source_counterparty_audit]', 'payables') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        payables : payables
    */
	source_counterparty_audit ADD payables INT NULL
END

IF OBJECT_ID(N'[dbo].[source_counterparty_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[source_counterparty_audit]', 'receivables') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        receivables : receivables
    */
	source_counterparty_audit ADD receivables INT NULL
END

IF OBJECT_ID(N'[dbo].[source_counterparty_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[source_counterparty_audit]', 'confirmation') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        confirmation : confirmation
    */
	source_counterparty_audit ADD confirmation INT NULL
END

IF OBJECT_ID(N'[dbo].[source_counterparty_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[source_counterparty_audit]', 'counterparty_status') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        counterparty_status : counterparty_status
    */
	source_counterparty_audit ADD counterparty_status INT NULL
END

IF OBJECT_ID(N'[dbo].[source_counterparty_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[source_counterparty_audit]', 'analyst') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        analyst : analyst
    */
	source_counterparty_audit ADD analyst VARCHAR(200) NULL
END

IF OBJECT_ID(N'[dbo].[source_counterparty_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[source_counterparty_audit]', 'credit') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        credit : credit
    */
	source_counterparty_audit ADD credit VARCHAR(MAX) NULL
END

IF OBJECT_ID(N'[dbo].[source_counterparty_audit]', N'U') IS NOT NULL AND COL_LENGTH(N'[dbo].[source_counterparty_audit]', 'liquidation_loc_id') IS NULL
BEGIN
	ALTER TABLE 
	 /**
        Columns
        liquidation_loc_id : liquidation_loc_id
    */
	source_counterparty_audit ADD liquidation_loc_id INT NULL
END
