IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19400, 'Logical Term', 1, 'Logical Term', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19400 - Logical Term.'
END
ELSE
BEGIN
	PRINT 'Static data type 19400 - Logical Term already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19400)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19400, 19400, 'Current Day', 'Current Day', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19400 - Current Day.'
END
ELSE
BEGIN
	PRINT 'Static data value 19400 - Current Day already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19401)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19401, 19400, 'Next Day', 'Next Day', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19401 - Next Day.'
END
ELSE
BEGIN
	PRINT 'Static data value 19401 - Next Day already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19402)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19402, 19400, 'Next Month', 'Next Month', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19402 - Next Month.'
END
ELSE
BEGIN
	PRINT 'Static data value 19402 - Next Month already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19403)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19403, 19400, 'Current Business Week', 'Current Business Week', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19403 - Current Business Week.'
END
ELSE
BEGIN
	PRINT 'Static data value 19403 - Current Business Week already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19404)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19404, 19400, 'Next Business Week', 'Next Business Week', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19404 - Next Business Week.'
END
ELSE
BEGIN
	PRINT 'Static data value 19404 - Next Business Week already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19405)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19405, 19400, 'Current Quarter', 'Current Quarter', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19405 - Current Quarter.'
END
ELSE
BEGIN
	PRINT 'Static data value 19405 - Current Quarter already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19406)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19406, 19400, 'Next Quarter', 'Next Quarter', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19406 - Next Quarter.'
END
ELSE
BEGIN
	PRINT 'Static data value 19406 - Next Quarter already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19407)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19407, 19400, 'Next Year', 'Next Year', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19407 - Next Year.'
END
ELSE
BEGIN
	PRINT 'Static data value 19407 - Next Year already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
