SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20709)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20709, 20700, 'Initial', 'Initial', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20700 - Initial.'
END
ELSE
BEGIN
	PRINT 'Static data value 20709 - Initial already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20710)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20710, 20700, 'Analyst Approved', 'Analyst Approved', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20710 - Analyst Approved.'
END
ELSE
BEGIN
	PRINT 'Static data value 20710 - Analyst Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20711)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20711, 20700, 'Manager Approved', 'Manager Approved', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20711 - Manager Approved.'
END
ELSE
BEGIN
	PRINT 'Static data value 20711 - Manager Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF