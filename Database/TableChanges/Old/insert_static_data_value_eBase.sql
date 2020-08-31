SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4043)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4043, 4000, 'eBase', 'eBase', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4043 - eBase.'
END
ELSE
BEGIN
	PRINT 'Static data value 4043 - eBase already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF