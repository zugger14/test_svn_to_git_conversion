SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2156)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2156, 2150, 'Deal', 'Deal', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2156 - Deal.'
END
ELSE
BEGIN
	PRINT 'Static data value 2156 - Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
