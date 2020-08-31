SET IDENTITY_INSERT external_source_import ON

IF NOT EXISTS (SELECT 'x' FROM external_source_import WHERE source_system_id = 12 AND data_type_id = 4008) 
BEGIN 
	INSERT INTO external_source_import( esi_id,source_system_id,data_type_id,create_ts,create_user)
	VALUES (16, 12, 4008,'2009-11-17', 'sa')
	PRINT 'Value INSERTED in table external_source_import'
END

SET IDENTITY_INSERT external_source_import OFF






