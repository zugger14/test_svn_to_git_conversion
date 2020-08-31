DECLARE @fk_name VARCHAR(100)
DECLARE @sql VARCHAR(1000)

IF EXISTS(SELECT 'X' FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID(N'static_data_value') AND parent_object_id = OBJECT_ID(N'counterparty_certificate'))
BEGIN
	SELECT @fk_name = name 
	FROM sys.foreign_keys
	WHERE referenced_object_id = OBJECT_ID(N'static_data_value') AND parent_object_id = OBJECT_ID(N'counterparty_certificate')

	SET @sql = '
	ALTER TABLE counterparty_certificate DROP CONSTRAINT ' + @fk_name + '
	ALTER TABLE counterparty_certificate 
	ADD CONSTRAINT FK_counterparty_certificate_documents_type_certificate_id FOREIGN KEY (certificate_id) REFERENCES dbo.documents_type(document_id)'
	EXEC(@sql)
END