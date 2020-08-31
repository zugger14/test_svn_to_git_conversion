SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21405)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21405, 21400, 'Excel', 'Excel', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21405 - Excel.'
END
ELSE
BEGIN
	PRINT 'Static data value 21405 - Excel already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
