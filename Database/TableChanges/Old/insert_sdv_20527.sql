SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20527)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20527, 20500, 'Scheduling - Post Insert', 'Scheduling - Post Insert', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20527 - Scheduling - Post Insert.'
END
ELSE
BEGIN
	PRINT 'Static data value 20527 - Scheduling - Post Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
