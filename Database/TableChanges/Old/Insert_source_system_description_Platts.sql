SET IDENTITY_INSERT source_system_description ON

IF NOT EXISTS (SELECT 'x' FROM source_system_description WHERE source_system_name LIKE '%Platts%') 
BEGIN 
	INSERT INTO source_system_description( source_system_id,source_system_name,connection_param1,connection_param2,connection_param3,system_name_value_id,create_user,create_ts,update_user,update_ts)
	VALUES (12, 'Platts', 'self', 'db', 'db', 600, 'farrms_admin', '2009-11-17', 'farrms_admin', '2009-11-17')
	PRINT 'Platts value INSERTED in table source_system_description'
END

SET IDENTITY_INSERT source_system_description OFF
