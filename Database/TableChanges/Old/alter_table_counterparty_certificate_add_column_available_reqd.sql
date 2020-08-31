IF NOT EXISTS(SELECT 'X' FROM information_schema.columns WHERE table_name = 'counterparty_certificate' AND column_name='available_reqd')
BEGIN
	ALTER TABLE counterparty_certificate 
	ADD available_reqd CHAR(1) NOT NULL
END