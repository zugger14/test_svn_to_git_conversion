IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 41000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (41000, 'Cycle', 1, '', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 41000 - Cycle.'
END
ELSE
BEGIN
	PRINT 'Static data type 41000 - Cycle already EXISTS.'
END	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 41000)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (41000, 41000, 'Manual Overwrite', 'Manual Overwrite', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 41000 - Manual Overwrite.'
END
ELSE
BEGIN
	PRINT 'Static data value 41000 - Manual Overwrite already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 41001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (41001, 41000, 'ID 1', 'ID 1', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 41001 - ID 1.'
END
ELSE
BEGIN
	PRINT 'Static data value 41001 - ID 1 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 41002)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (41002, 41000, 'ID 2', 'ID 2', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 41002 - ID 2.'
END
ELSE
BEGIN
	PRINT 'Static data value 41002 - ID 2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF