SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39003)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39003, 39000, 'Fuel Loss Group', 'Fuel Loss Group', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39001 - Fuel Loss Group.'
END
ELSE
BEGIN
	PRINT 'Static data value 39003 - Fuel Loss Group already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
