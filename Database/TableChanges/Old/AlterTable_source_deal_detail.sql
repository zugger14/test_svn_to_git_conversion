/*
* Alter table confirm_status START
*/
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'source_deal_detail' AND c.COLUMN_NAME = 'multiplier' AND c.DATA_TYPE = 'FLOAT')
BEGIN
	ALTER TABLE source_deal_detail
	ADD [multiplier] FLOAT
END
Go
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'source_deal_detail' AND c.COLUMN_NAME = 'adder_currency_id' AND c.DATA_TYPE = 'INT')
BEGIN
	ALTER TABLE source_deal_detail
	ADD [adder_currency_id] INT
END

GO
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'source_deal_detail' AND c.COLUMN_NAME = 'fixed_cost_currency_id' AND c.DATA_TYPE = 'INT')
BEGIN
	ALTER TABLE source_deal_detail
	ADD [fixed_cost_currency_id] INT
END

GO
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'source_deal_detail' AND c.COLUMN_NAME = 'formula_currency_id' AND c.DATA_TYPE = 'INT')
BEGIN
	ALTER TABLE source_deal_detail
	ADD [formula_currency_id] INT
END
