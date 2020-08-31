SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21404)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21404, 21400, 'Web Services', 'Web Services', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21404 - Web Services.'
END
ELSE
BEGIN
	PRINT 'Static data value 21404 - Web Services already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
