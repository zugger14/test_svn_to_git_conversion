
IF COL_LENGTH('pratos_stage_deal_header', 'notification_status') IS  NULL
	ALTER TABLE pratos_stage_deal_header ADD notification_status VARCHAR(10)
GO

IF COL_LENGTH('pratos_stage_deal_header', 'create_ts') IS  NULL
	ALTER TABLE pratos_stage_deal_header ADD create_ts DATETIME
GO
