SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 8)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (8, 1, 'Reporting Admin Group', 'Reporting Admin Group', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 8 - Reporting Admin Group.'
END
ELSE
BEGIN
	PRINT 'Static data value 8 - Reporting Admin Group already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
