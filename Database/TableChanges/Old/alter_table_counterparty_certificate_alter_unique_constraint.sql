IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_counterparty_id_certificate_name_effective_date')
BEGIN
	-- Delete the unique constraint.  
	ALTER TABLE dbo.counterparty_certificate   
	DROP CONSTRAINT UC_counterparty_id_certificate_name_effective_date;
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_counterparty_id_certificate_name_effective_date')
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UC_counterparty_certificate_effective_expiration_date')
	BEGIN
		-- Add unique constraint.
		ALTER TABLE counterparty_certificate
		ADD CONSTRAINT UC_counterparty_certificate_effective_expiration_date UNIQUE (counterparty_id, certificate_id, effective_date, expiration_date)
	END
END