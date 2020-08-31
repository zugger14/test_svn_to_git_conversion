SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19203)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19203, 19200, 'Beginning of the Year', 'Beginning of the Year', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19203 - Beginning of the Year.'
END
ELSE
BEGIN
	PRINT 'Static data value 19203 - Beginning of the Year already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


UPDATE static_data_value SET code = 'Beginning of the Month', [description] = 'Beginning of the Month' WHERE [value_id] = 19201
PRINT 'Updated Static value 19201 - Beginning of the Month.'
