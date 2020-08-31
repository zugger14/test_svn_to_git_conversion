IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19800, 'Report Option', 1, 'Report Option', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19800 - Report Option.'
END
ELSE
BEGIN
	PRINT 'Static data type 19800 - Report Option already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19801)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19801, 19800, 'Summary', 'Summary', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19801 - Summary.'
END
ELSE
BEGIN
	PRINT 'Static data value 19801 - Summary already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19802)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19802, 19800, 'Detail', 'Detail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19802 - Detail.'
END
ELSE
BEGIN
	PRINT 'Static data value 19802 - Detail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
