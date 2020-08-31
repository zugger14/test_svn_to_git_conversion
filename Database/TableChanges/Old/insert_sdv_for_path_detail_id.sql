SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5606)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5606, 5500, 'Path Detail ID', 'Path Detail ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5606 - Path Detail ID.'
END
ELSE
BEGIN
	PRINT 'Static data value -5606 - Path Detail ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
