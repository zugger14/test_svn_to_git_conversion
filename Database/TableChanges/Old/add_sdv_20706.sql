SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20706)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20706, 20700, 'Ready to send', 'Ready to send', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20706 - Ready to send.'
END
ELSE
BEGIN
	PRINT 'Static data value 20706 - Ready to send already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
