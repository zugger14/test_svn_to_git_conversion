SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 821)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (821, 800, 'RollingAVG', 'This function is used to find Rolling Average', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 821 - RollingAVG.'
END
ELSE
BEGIN
	PRINT 'Static data value 821 - RollingAVG already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 868)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (868, 800, 'PriceAdder', 'PriceAdder', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 868 - PriceAdder.'
END
ELSE
BEGIN
	PRINT 'Static data value 868 - PriceAdder already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 869)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (869, 800, 'PriceMultiplier', 'PriceMultiplier', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 869 - PriceMultiplier.'
END
ELSE
BEGIN
	PRINT 'Static data value 869 - PriceMultiplier already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF