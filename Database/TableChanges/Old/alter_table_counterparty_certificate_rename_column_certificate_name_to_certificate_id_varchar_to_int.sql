IF EXISTS(SELECT 'X' FROM information_schema.columns WHERE table_name = 'counterparty_certificate' AND column_name='certificate_name')
BEGIN
	ALTER TABLE counterparty_certificate 
	DROP CONSTRAINT UC_counterparty_id_certificate_name_effective_date
	
	ALTER TABLE counterparty_certificate 
	ALTER COLUMN certificate_name INT
	
	EXEC sp_RENAME 'counterparty_certificate.certificate_name', 'certificate_id', 'COLUMN'

	ALTER TABLE counterparty_certificate
	ADD FOREIGN KEY (certificate_id) REFERENCES static_data_value(value_id)

	ALTER TABLE counterparty_certificate
	ADD CONSTRAINT UC_counterparty_id_certificate_name_effective_date UNIQUE (counterparty_id, certificate_id, effective_date)
END