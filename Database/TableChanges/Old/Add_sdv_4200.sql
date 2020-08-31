SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4200)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4200, 4200, 'sshrestha', 'System User', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4200 - sshrestha.'
END
ELSE
BEGIN
	PRINT 'Static data value 4200 - sshrestha already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
