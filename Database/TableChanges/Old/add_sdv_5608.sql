SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5608)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5608, 5600, 'Request for Validation', 'Request for Validation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5608 - Request for Validation.'
END
ELSE
BEGIN
	PRINT 'Static data value 5608 - Request for Validation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
