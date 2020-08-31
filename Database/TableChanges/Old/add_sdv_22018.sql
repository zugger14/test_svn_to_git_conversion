SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22018)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22018, 22000, 'Static Data Detail', 'Static Data Detail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22018 - Static Data Detail.'
END
ELSE
BEGIN
	PRINT 'Static data value 22018 - Static Data Detail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF