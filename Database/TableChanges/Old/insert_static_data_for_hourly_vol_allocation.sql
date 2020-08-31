IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 17600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (17600, 'Hourly Volume Allocation Type', 1, 'Hourly Volume Allocation Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 17600 - Hourly Volume Allocation Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 17600 - Hourly Volume Allocation Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17600)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17600, 17600, 'Monthly Average Allocation', 'Monthly Average Allocation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17600 - Monthly Average Allocation.'
END
ELSE
BEGIN
	PRINT 'Static data value 17600 - Monthly Average Allocation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17601)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17601, 17600, 'TOU Allocation', 'TOU Allocation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17601 - TOU Allocation.'
END
ELSE
BEGIN
	PRINT 'Static data value 17601 - TOU Allocation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17602)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17602, 17600, 'Daily Allocation', 'Daily Allocation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 17602 - Daily Allocation.'
END
ELSE
BEGIN
	PRINT 'Static data value 17602 - Daily Allocation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

