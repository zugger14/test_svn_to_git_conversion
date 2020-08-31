IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 39200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (39200, 'Transportation Type', 1, 'Transportation Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 39200 - Transportation Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 39200 - Transportation Type already EXISTS.'
END



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39200)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39200, 39200, 'Truck', 'Truck', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39200 - Truck.'
END
ELSE
BEGIN
	PRINT 'Static data value 39200 - Truck already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39201)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39201, 39200, 'Rail', 'Rail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39201 - Rail.'
END
ELSE
BEGIN
	PRINT 'Static data value 39201 - Rail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39202)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39202, 39200, 'Pipeline', 'Pipeline', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39202 - Pipeline.'
END
ELSE
BEGIN
	PRINT 'Static data value 39202 - Pipeline already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39203)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39203, 39200, 'Vessel', 'Vessel', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39203 - Vessel.'
END
ELSE
BEGIN
	PRINT 'Static data value 39203 - Vessel already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39204)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39204, 39200, 'Barge', 'Barge', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39204 - Barge.'
END
ELSE
BEGIN
	PRINT 'Static data value 39204 - Barge already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39205)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39205, 39200, 'In Tank', 'In Tank', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39205 - In Tank.'
END
ELSE
BEGIN
	PRINT 'Static data value 39205 - In Tank already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39206)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39206, 39200, 'PTO', 'PTO', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39206 - PTO.'
END
ELSE
BEGIN
	PRINT 'Static data value 39206 - PTO already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

