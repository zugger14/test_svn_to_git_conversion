IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 24000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (24000, 'Shift Group', 1, 'Shift Group', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 24000 - Shift Group.'
END
ELSE
BEGIN
	PRINT 'Static data type 24000 - Shift Group already EXISTS.'
END


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 24001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (24001, 24000, 'Index', 'Index', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 24001 - Index.'
END
ELSE
BEGIN
	PRINT 'Static data value 24001 - Index already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 24002)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (24002, 24000, 'Index Group', 'Index Group', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 24002 - Index Group.'
END
ELSE
BEGIN
	PRINT 'Static data value 24002 - Index Group already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 24003)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (24003, 24000, 'Commodity', 'Commodity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 24003 - Commodity.'
END
ELSE
BEGIN
	PRINT 'Static data value 24003 - Commodity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

