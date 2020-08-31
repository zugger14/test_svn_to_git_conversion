SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19204)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19204, 19200, 'Comma Seperated', 'Comma Seperated', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19204 - Comma Seperated.'
END
ELSE
BEGIN
	PRINT 'Static data value 19204 - Comma Seperated already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
