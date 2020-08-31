IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 23800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (23800, 'Regression Group', 1, 'Regression Group', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 23800 - Regression Group.'
END
ELSE
BEGIN
	PRINT 'Static data type 23800 - Regression Group already EXISTS.'
END	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23801)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23801, 23800, 'Regression Group 1', 'Regression Group 1', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23801 - Regression Group 1.'
END
ELSE
BEGIN
	PRINT 'Static data value 23801 - Regression Group 1 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23802)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23802, 23800, 'Regression Group 2', 'Regression Group 2', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23802 - Regression Group 2.'
END
ELSE
BEGIN
	PRINT 'Static data value 23802 - Regression Group 2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
