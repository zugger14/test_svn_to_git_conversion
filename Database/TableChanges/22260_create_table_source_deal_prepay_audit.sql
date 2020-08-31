IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[source_deal_prepay_audit]') AND [type] IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[source_deal_prepay_audit] (
	/**
		source_deal_prepay_audit
		Columns
		[source_deal_prepay_audit_id] : Identity Key.
		[source_deal_prepay_id] : Prepat Identity Key.
		[prepay] : Save the id of UDF with internal_field_type 18724 and 18736.
		[value] : Stores the value if the prepay is not of formula type and percentage.
		[percentage] : Stores the value if the prepay is not of formula type and value.
		[formula_id] : Stores the value if the prepay is of formula type.
		[settlement_date] : Date field to store prepay settlement date.
		[settlement_calendar] : Drop down field which save the saves the value of holiday calendar.
		[settlement_days] : Integer field to save settlement days.
		[payment_date] : Date field to save payment date.
		[payment_calendar] : Drop down field which save the saves the value of holiday calendar. 
		[payment_days] : Integer field to save payment days.
		[granularity] : Dropdown field to save granularity.
		[source_deal_header_id] : Deal Id, it is referenced to source_deal_header_id from source_deal_header
		[user_action] : Since it is audit table, save the user action whether it insert, update or delete.
	*/
		[source_deal_prepay_audit_id] INT IDENTITY(1, 1) CONSTRAINT [pk_source_deal_prepay_audit_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[source_deal_prepay_id] INT,
		[prepay] INT NULL,
		[value] VARCHAR(1000) NULL,
		[percentage] FLOAT NULL,
		[formula_id] INT NULL,
		[settlement_date] DATETIME NULL,
		[settlement_calendar] INT NULL,
		[settlement_days] INT NULL,
		[payment_date] DATETIME NULL,
		[payment_calendar] INT NULL,
		[payment_days] INT NULL,
		[granularity] INT NULL,
		[source_deal_header_id] INT NOT NULL,
		[create_user] VARCHAR(100) NULL DEFAULT [dbo].[FNADBUser](),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(100) NULL,
		[update_ts] DATETIME NULL,
		[user_action] VARCHAR(10) NULL
	)
END
GO