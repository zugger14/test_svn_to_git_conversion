EXEC sp_fulltext_column      
@tabname =  'source_counterparty' , 
@colname =  'counterparty_contact_notes' , 
@action =  'drop' 
GO

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_counterparty' AND COLUMN_NAME = 'counterparty_contact_notes')
BEGIN
	ALTER TABLE source_counterparty ALTER COLUMN counterparty_contact_notes NVARCHAR(200) NULL
END

EXEC sp_fulltext_column      
@tabname =  'source_counterparty' , 
@colname =  'counterparty_contact_notes' , 
@action =  'add' 
GO



IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'maintain_udf_static_data_detail_values' AND COLUMN_NAME = 'static_data_udf_values')
BEGIN
	ALTER TABLE maintain_udf_static_data_detail_values ALTER COLUMN static_data_udf_values NVARCHAR(4000) NULL
END

