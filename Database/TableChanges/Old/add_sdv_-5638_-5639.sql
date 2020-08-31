SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5638)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5638, 5500, 'Exposure Type', 'Exposure Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5638 - Exposure Type.'
END
ELSE
BEGIN
	PRINT 'Static data value -5638 - Exposure Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5639)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5639, 5500, 'Exposure Index', 'Exposure Index', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5639 - Exposure Index.'
END
ELSE
BEGIN
	PRINT 'Static data value -5639 - Exposure Index already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
