IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 4100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (4100, 'Fixing', 1, 'Fixing', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 4100 - Fixing.'
END
ELSE
BEGIN
	PRINT 'Static data type 4100 - Fixing already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4100)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4100, 4100, 'Fixed', 'Fixed', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4100 - Fixed.'
END
ELSE
BEGIN
	PRINT 'Static data value 4100 - Fixed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4101)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4101, 4100, 'Original', 'Original', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4101 - Original.'
END
ELSE
BEGIN
	PRINT 'Static data value 4101 - Original already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF