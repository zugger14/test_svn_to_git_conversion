SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4064)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4064, 4000, 'Pipeline_Cut_Import', 'Pipeline Cut Import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4064 - Pipeline_Cut_Import.'
END
ELSE
BEGIN
	PRINT 'Static data value 4064 - Pipeline_Cut_Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


-- Add in external source Import
IF NOT EXISTS ( SELECT * FROM external_source_import WHERE data_type_id = 4064)
BEGIN
	INSERT INTO external_source_import ( source_system_id, data_type_id)
	VALUES (2, 4064)
	PRINT 'Inserted 4064 in external_source_import'
END
ELSE
	PRINT '4064 already exists in external_source_import'

