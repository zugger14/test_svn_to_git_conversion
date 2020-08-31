IF EXISTS(SELECT 'X' FROM information_schema.columns WHERE table_name = 'counterparty_certificate' AND column_name='certificate_id')
BEGIN
	ALTER TABLE counterparty_certificate 
	ALTER COLUMN certificate_id INT
END

IF NOT EXISTS(SELECT 'X' FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID(N'documents_type') AND parent_object_id = OBJECT_ID(N'counterparty_certificate'))
BEGIN
	ALTER TABLE counterparty_certificate
	ADD CONSTRAINT FK_counterparty_certificate_id  FOREIGN KEY (certificate_id) REFERENCES documents_type(document_id)
END