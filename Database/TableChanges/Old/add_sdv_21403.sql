SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21403)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21403, 21400, 'SSIS', 'SSIS', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21403 - SSIS.'
END
ELSE
BEGIN
	PRINT 'Static data value 21403 - SSIS already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
