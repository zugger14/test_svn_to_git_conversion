SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17808)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17808, 17800, 'Login Credentials', 'Login Credentials', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17808 - Login Credentials.'
END
ELSE
BEGIN
	PRINT 'Static data value 17808 - Login Credentials already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17809)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17809, 17800, 'Login Credentials Update', 'Login Credentials Update', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17809 - Login Credentials Update.'
END
ELSE
BEGIN
	PRINT 'Static data value 17809 - Login Credentials Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

