IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 21400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (21400, 'Data Source', 1, 'Data Source', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 21400 - Data Source.'
END
ELSE
BEGIN
	PRINT 'Static data type 21400 - Data Source already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21400)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21400, 21400, 'Flat File', 'Flat File', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21400 - Flat File.'
END
ELSE
BEGIN
	PRINT 'Static data value 21400 - Flat File already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21401)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21401, 21400, 'Link Server', 'Link Server', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21401 - Link Server.'
END
ELSE
BEGIN
	PRINT 'Static data value 21401 - Link Server already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
