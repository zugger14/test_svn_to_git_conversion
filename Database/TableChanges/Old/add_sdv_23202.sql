SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23202)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (23202, 23200, 'Portfolio Group', 'Portfolio Group', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 23202 - Portfolio Group.'
END
ELSE
BEGIN
	PRINT 'Static data value 23202 - Portfolio Group already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF