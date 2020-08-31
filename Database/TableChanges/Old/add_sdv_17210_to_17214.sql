SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17210)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17210, 17200, 'Initial', 'Initial', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17210 - Initial.'
END
ELSE
BEGIN
	PRINT 'Static data value 17210 - Initial already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17211)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17211, 17200, 'Analyst Approved', 'Analyst Approved', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17211 - Analyst Approved.'
END
ELSE
BEGIN
	PRINT 'Static data value 17211 - Analyst Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17212)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17212, 17200, 'Manager Approved', 'Manager Approved', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17212 - Manager Approved.'
END
ELSE
BEGIN
	PRINT 'Static data value 17212 - Manager Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17213)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17213, 17200, 'Trader Approved', 'Trader Approved', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17213 - Trader Approved.'
END
ELSE
BEGIN
	PRINT 'Static data value 17213 - Trader Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17214)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17214, 17200, 'Received Confirmation', 'Received Confirmation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17214 - Received Confirmation.'
END
ELSE
BEGIN
	PRINT 'Static data value 17214 - Received Confirmation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
