

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5620)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5620, 5500, 'UOM Conversion', 'UOM Conversion', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5620 - UOM Conversion.'
END
ELSE
BEGIN
	PRINT 'Static data value -5620 - UOM Conversion already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5633)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5633, 5500, 'UOM Conversion Divider', 'UOM Conversion Divider', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5633 - UOM Conversion Divider.'
END
ELSE
BEGIN
	PRINT 'Static data value -5633 - UOM Conversion Divider already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF






