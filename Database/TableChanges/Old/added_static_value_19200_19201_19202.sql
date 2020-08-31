IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19200, 'Display format', 1, 'Display format', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19200 - Display format.'
END
ELSE
BEGIN
	PRINT 'Static data type 19200 - Display format already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19201)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19201, 19200, 'Beginning of the Year', 'Beginning of the Year', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19201 - Beginning of the Year.'
END
ELSE
BEGIN
	PRINT 'Static data value 19201 - Beginning of the Year already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19202)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19202, 19200, 'Year', 'Year', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19202 - Year.'
END
ELSE
BEGIN
	PRINT 'Static data value 19202 - Year already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


