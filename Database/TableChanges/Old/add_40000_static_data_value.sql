
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 40000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (40000, 'Function Argument Reference Field', 1, 'Function Argument Reference Field', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 40000 - Function Argument Reference Field.'
END
ELSE
BEGIN
	PRINT 'Static data type 40000 - Function Argument Reference Field already EXISTS.'
END

go

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 40000)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (40000, 40000, 'source_curve_def_id', 'Curve ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 40000 - source_curve_def_id.'
END
ELSE
BEGIN
	PRINT 'Static data value 40000 - source_curve_def_id already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 40001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (40001, 40000, 'source_counterparty_id', 'Counterparty ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 40001 - source_counterparty_id.'
END
ELSE
BEGIN
	PRINT 'Static data value 40001 - source_counterparty_id already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 40002)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (40002, 40000, 'meter_id', 'Meter ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 40002 - meter_id.'
END
ELSE
BEGIN
	PRINT 'Static data value 40002 - meter_id already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 40003)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (40003, 40000, 'value_id', 'value_id', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 40003 - value_id.'
END
ELSE
BEGIN
	PRINT 'Static data value 40003 - value_id already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

