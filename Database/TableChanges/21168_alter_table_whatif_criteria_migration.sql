IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'whatif_criteria_migration' AND COLUMN_NAME = 'internal_counterparty_id')
BEGIN
	ALTER TABLE whatif_criteria_migration ADD internal_counterparty_id INT
END

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'whatif_criteria_migration' AND COLUMN_NAME = 'contract_id')
BEGIN
	ALTER TABLE whatif_criteria_migration ADD contract_id INT
END