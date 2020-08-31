IF OBJECT_ID(N'setup_submission_rule', N'U') IS NOT NULL
BEGIN
	PRINT 'Table already exists.'
END
ELSE
BEGIN
	CREATE TABLE setup_submission_rule (
		[rule_id] INT IDENTITY(1, 1) CONSTRAINT [PK_setup_submission_rule_id] PRIMARY KEY NOT NULL,
		[submission_type_id] INT NULL,
		[confirmation_type] INT NULL,
		[legal_entity_id] INT NULL,
		[sub_book_id] INT NULL,
		[contract_id] INT NULL,
		[counterparty_id2] INT NULL,
		[deal_type_id] INT NULL,
		[deal_sub_type_id] INT NULL,
		[deal_template_id] INT NULL,
		[commodity_id] INT NULL,
		[location_group_id] INT NULL,
		[location_id] INT NULL,
		[counterparty_id] INT NULL,
		[counterpaty_type] CHAR(1) NULL,
		[index_group] INT NULL,
		[entity_type] INT NULL,
		[curve_id] INT NULL,
		[buy_sell] CHAR(1) NULL,
		[confirm_status_id] INT NULL,
		[deal_status_id] INT NULL,
		[create_user] VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(100) NULL,
		[update_ts] DATETIME NULL
	)
END