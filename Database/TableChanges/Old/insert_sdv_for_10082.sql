/*
* inserting static data value for account status.
* sligal
* 11/22/2012
*/
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10082)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (10082, 10082, 'Active', 'Active', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 10082 - Active.'
END
ELSE
BEGIN
	PRINT 'Static data value 10082 - Active already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10083)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (10083, 10082, 'Inactive', 'Inactive', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 10083 - Inactive.'
END
ELSE
BEGIN
	PRINT 'Static data value 10083 - Inactive already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10084)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (10084, 10082, 'New', 'New', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 10084 - New.'
END
ELSE
BEGIN
	PRINT 'Static data value 10084 - New already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10085)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (10085, 10082, 'No Trade', 'No Trade', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 10085 - No Trade.'
END
ELSE
BEGIN
	PRINT 'Static data value 10085 - No Trade already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
