SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5535)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5535, 5500, 'Fixed_Commodity_Onpeak', 'Fixed Commodity Onpeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5535 - Fixed_Commodity_Onpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5535 - Fixed_Commodity_Onpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5536)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5536, 5500, 'Fixed_Commodity_Offpeak', 'Fixed Commodity Offpeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5536 - Fixed_Commodity_Offpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5536 - Fixed_Commodity_Offpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5537)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5537, 5500, 'Fixed_Volume_Offpeak', 'Fixed Volume Offpeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5537 - Fixed_Volume_Offpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5537 - Fixed_Volume_Offpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5538)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5538, 5500, 'Fixed_Volume_Onpeak', 'Fixed Volume Onpeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5538 - Fixed_Volume_Onpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5538 - Fixed_Volume_Onpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5539)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5539, 5500, 'Fixed_Volume_BSLD', 'Fixed Volume BSLD', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5539 - Fixed_Volume_BSLD.'
END
ELSE
BEGIN
	PRINT 'Static data value -5539 - Fixed_Volume_BSLD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
