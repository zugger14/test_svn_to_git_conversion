SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27400)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27400, 27400, 'Math', 'Math', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27400 - Math.'
END
ELSE
BEGIN
	PRINT 'Static data value 27400 - Math already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27401)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27401, 27400, 'Deal', 'Deal', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27401 - Deal.'
END
ELSE
BEGIN
	PRINT 'Static data value 27401 - Deal already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27402)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27402, 27400, 'Logical', 'Logical', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27402 - Logical.'
END
ELSE
BEGIN
	PRINT 'Static data value 27402 - Logical already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27403)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27403, 27400, 'Price', 'Price', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27403 - Price.'
END
ELSE
BEGIN
	PRINT 'Static data value 27403 - Price already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27404)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27404, 27400, 'PNL', 'PNL', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27404 - PNL.'
END
ELSE
BEGIN
	PRINT 'Static data value 27404 - PNL already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27405)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27405, 27400, 'Date Time', 'Date Time', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27405 - Date Time.'
END
ELSE
BEGIN
	PRINT 'Static data value 27405 - Date Time already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27406)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27406, 27400, 'Operators', 'Operators', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27406 - Operators.'
END
ELSE
BEGIN
	PRINT 'Static data value 27406 - Operators already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27407)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27407, 27400, 'Others', 'Others', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27407 - Others.'
END
ELSE
BEGIN
	PRINT 'Static data value 27407 - Others already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27408)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27408, 27400, 'Volume', 'Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27408 - Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value 27408 - Volume already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27409)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27409, 27400, 'Reference', 'Reference', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27409 - Reference.'
END
ELSE
BEGIN
	PRINT 'Static data value 27409 - Reference already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

