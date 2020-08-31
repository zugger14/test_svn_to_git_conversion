IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 17800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (17800, 'Manage Documents', 1, 'Manage Documents', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 17800 - Manage Documents.'
END
ELSE
BEGIN
	PRINT 'Static data type 17800 - Manage Documents already EXISTS.'
END



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17810)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17810, 17800, 'Manage Documents', 'Manage Documents', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17810 - Manage Documents.'
END
ELSE
BEGIN
	PRINT 'Static data value 17810 - Manage Documents already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF