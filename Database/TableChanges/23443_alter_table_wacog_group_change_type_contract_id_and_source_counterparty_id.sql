IF COL_LENGTH('wacog_group', 'source_counterparty_id') IS NOT NULL
	ALTER TABLE wacog_group ALTER COLUMN source_counterparty_id VARCHAR(MAX)

IF COL_LENGTH('wacog_group', 'contract_id') IS NOT NULL
	ALTER TABLE wacog_group ALTER COLUMN contract_id VARCHAR(MAX)

GO