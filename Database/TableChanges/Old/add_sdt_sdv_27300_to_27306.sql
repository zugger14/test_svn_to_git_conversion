IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 27300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (27300, 'Dashboard Template Datatype', 1, 'Dashboard Template Datatype', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 27300 - Dashboard Template Datatype.'
END
ELSE
BEGIN
	PRINT 'Static data type 27300 - Dashboard Template Datatype already EXISTS.'
END


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27301)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27301, 27300, 'Deal Based Position', 'Deal Based Position', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27301 - Deal Based Position.'
END
ELSE
BEGIN
	PRINT 'Static data value 27301 - Deal Based Position already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27302)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27302, 27300, 'Actual', 'Actual', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27302 - Actual.'
END
ELSE
BEGIN
	PRINT 'Static data value 27302 - Actual already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27303)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27303, 27300, 'Forecast', 'Forecast', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27303 - Forecast.'
END
ELSE
BEGIN
	PRINT 'Static data value 27303 - Forecast already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27304)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27304, 27300, 'Time Series Data', 'Time Series Data', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27304 - Time Series Data.'
END
ELSE
BEGIN
	PRINT 'Static data value 27304 - Time Series Data already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27305)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27305, 27300, 'What-If', 'What-If', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27305 - What-If.'
END
ELSE
BEGIN
	PRINT 'Static data value 27305 - What-If already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27306)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27306, 27300, 'Custom', 'Custom', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27306 - Custom.'
END
ELSE
BEGIN
	PRINT 'Static data value 27306 - Custom already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27307)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (27307, 27300, 'Sub Total', 'Sub Total', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 27307 - Sub Total.'
END
ELSE
BEGIN
	PRINT 'Static data value 27307 - Sub Total already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
