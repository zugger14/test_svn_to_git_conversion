IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_bank_info' AND COLUMN_NAME = 'accountname')
BEGIN
	ALTER TABLE counterparty_bank_info ADD accountname varchar(50)
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_bank_info' AND COLUMN_NAME = 'reference')
BEGIN
	ALTER TABLE counterparty_bank_info ADD reference varchar(50)
END
