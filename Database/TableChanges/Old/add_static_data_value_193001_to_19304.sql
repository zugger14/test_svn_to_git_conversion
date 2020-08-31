Go

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19300, 'Default Value Date', 1, 'Default Value Date', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19300 - Default Value Date.'
END
ELSE
BEGIN
	PRINT 'Static data type 19300 - Default Value Date already EXISTS.'
END

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19301)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19301, 19300, 'Beginning of the Year', 'Beginning of the Year', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19301 - Beginning of the Year.'
END
ELSE
BEGIN
	PRINT 'Static data value 19301 - Beginning of the Year already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19302)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19302, 19300, 'Beginning of the Month', 'Beginning of the Month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19302 - Beginning of the Month.'
END
ELSE
BEGIN
	PRINT 'Static data value 19302 - Beginning of the Month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19303)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19303, 19300, 'End of the Month', 'End of the Month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19303 - End of the Month.'
END
ELSE
BEGIN
	PRINT 'Static data value 19303 - End of the Month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19304)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19304, 19300, 'End of the Year', 'End of the Year', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19304 - End of the Year.'
END
ELSE
BEGIN
	PRINT 'Static data value 19304 - End of the Year already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO