IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 26000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (26000, 'Event Rule Category', 1, 'Event Rule Category', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 26000 - Event Rule Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 26000 - Event Rule Category already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 26000)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (26000, 26000, 'General', 'General', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 26000 - General.'
END
ELSE
BEGIN
	PRINT 'Static data value 26000 - General already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
