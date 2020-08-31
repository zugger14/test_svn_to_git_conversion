IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 4000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (4000, 'Import Table Name', 1, 'Import Table Name', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 4000 - Import Table Name.'
END
ELSE
BEGIN
	PRINT 'Static data type 4000 - Import Table Name already EXISTS.'
END	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4040)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4040, 4000, 'term_code_mapping', 'Trayport', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4040 - term_code_mapping.'
END
ELSE
BEGIN
	PRINT 'Static data value 4040 - term_code_mapping already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	



