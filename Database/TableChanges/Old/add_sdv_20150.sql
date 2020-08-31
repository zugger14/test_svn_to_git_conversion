IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20150)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20150, 'Save at Calculation Granularity', 1, 'Save at Calculation Granularity', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20150 - Save at Calculation Granularity.'
END
ELSE
BEGIN
	PRINT 'Static data type 20150 - Save at Calculation Granularity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20150)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20150, 20150, 'MTM', 'MTM', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20150 - MTM.'
END
ELSE
BEGIN
	PRINT 'Static data value 20150 - MTM already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20151)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20151, 20150, 'Settlement', 'Settlement', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20151 - Settlement.'
END
ELSE
BEGIN
	PRINT 'Static data value 20151 - Settlement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20152)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20152, 20150, 'Both', 'Both', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20152 - Both.'
END
ELSE
BEGIN
	PRINT 'Static data value 20152 - Both already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
