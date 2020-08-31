IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 23500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (23500, 'Import Category', 1, 'Import Category', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 23500 - Import Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 23500 - Import Category already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23500)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23500, 23500, 'General', 'General', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23500 - General.'
END
ELSE
BEGIN
	PRINT 'Static data value 23500 - General already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
