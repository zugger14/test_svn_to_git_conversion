SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32201)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-32201, 32200, 'Confirm Email', 'Confirm Email', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -32201 - Confirm Email.'
END
ELSE
BEGIN
	PRINT 'Static data value -32201 - Confirm Email already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF