IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_contract_address' AND COLUMN_NAME = 'margin_provision')
BEGIN
	ALTER TABLE counterparty_contract_address ADD margin_provision INT
END