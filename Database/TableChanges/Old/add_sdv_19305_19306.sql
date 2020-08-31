SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19305)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19305, 19300, 'Same as Term Start', 'Same as Term Start', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19305 - Same as Term Start.'
END
ELSE
BEGIN
	PRINT 'Static data value 19305 - Same as Term Start already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19306)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19306, 19300, 'Month End of Term Start', 'Month End of Term Start', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19306 - Month End of Term Start.'
END
ELSE
BEGIN
	PRINT 'Static data value 19306 - Month End of Term Start already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
