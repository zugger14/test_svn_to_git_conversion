IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (20300, 'Line Item', 1, 'Line Item', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20300 - Line Item.'
END
ELSE
BEGIN
	PRINT 'Static data type 20300 - Line Item already EXISTS.'
END	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20301)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20301, 20300, 'Residue Shaped Risk', 'Residue Shaped Risk', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20301 - Residue Shaped Risk.'
END
ELSE
BEGIN
	PRINT 'Static data value 20301 - Residue Shaped Risk already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20302)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20302, 20300, 'Open Position', 'Open Position', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20302 - Open Position.'
END
ELSE
BEGIN
	PRINT 'Static data value 20302 - Open Position already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20303)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20303, 20300, 'Premium', 'Premium', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20303 - Premium.'
END
ELSE
BEGIN
	PRINT 'Static data value 20303 - Premium already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20304)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20304, 20300, 'Fees', 'Fees', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20304 - Fees.'
END
ELSE
BEGIN
	PRINT 'Static data value 20304 - Fees already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
