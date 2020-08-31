

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_audit' AND COLUMN_NAME = 'unit_fixed_flag')
BEGIN
	ALTER TABLE source_deal_header_audit ADD unit_fixed_flag char(1) NULL
END
GO
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_audit' AND COLUMN_NAME = 'broker_unit_fees')
BEGIN
	ALTER TABLE source_deal_header_audit ADD broker_unit_fees float NULL
END
GO
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_audit' AND COLUMN_NAME = 'broker_fixed_cost')
BEGIN
	ALTER TABLE source_deal_header_audit ADD broker_fixed_cost float NULL
END
GO
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_audit' AND COLUMN_NAME = 'broker_currency_id')
BEGIN
	ALTER TABLE source_deal_header_audit ADD broker_currency_id int NULL
END
GO
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_audit' AND COLUMN_NAME = 'deal_status')
BEGIN
	ALTER TABLE source_deal_header_audit ADD deal_status int NULL
END
GO
IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_audit' AND COLUMN_NAME = 'term_frequency')
BEGIN
	ALTER TABLE source_deal_header_audit ADD term_frequency char(1) NULL
END
GO

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_audit' AND COLUMN_NAME = 'option_settlement_date')
BEGIN
	ALTER TABLE source_deal_header_audit ADD option_settlement_date datetime NULL
END
GO
