SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5472)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5472, 5450, 'Expiration_Calendar', 'Expiration Calendar', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 5472 - Expiration_Calendar.'
END
ELSE
BEGIN
	PRINT 'Static data value 5472 - Expiration_Calendar already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
