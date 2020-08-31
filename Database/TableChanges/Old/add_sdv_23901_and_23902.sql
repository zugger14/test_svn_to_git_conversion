SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23901)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23901, 23900, 'Send', 'Send', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23901 - Send.'
END
ELSE
BEGIN
	PRINT 'Static data value 23901 - Send already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23902)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23902, 23900, 'Ready to Send', 'Ready to Send', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23902 - Ready to Send.'
END
ELSE
BEGIN
	PRINT 'Static data value 23902 - Ready to Send already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
