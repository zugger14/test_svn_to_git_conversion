
--type id for Delivery Method
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 21300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (21300, 'Delivery Method', 1, 'Delivery Method', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 21300 - Delivery Method.'
END
ELSE
BEGIN
	PRINT 'Static data type 21300 - Delivery Method already EXISTS.'
END

-- value_id for Delivery Method

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21301)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21301, 21300, 'Email', 'Email', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21301 - Email.'
END
ELSE
BEGIN
	PRINT 'Static data value 21301 - Email already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21302)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21302, 21300, 'Print', 'Print', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21302 - Print.'
END
ELSE
BEGIN
	PRINT 'Static data value 21302 - Print already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21303)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21303, 21300, 'Email and Print', 'Email and Print', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21303 - Email and Print.'
END
ELSE
BEGIN
	PRINT 'Static data value 21303 - Email and Print already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 21304)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (21304, 21300, 'Fax', 'Fax', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 21304 - Fax.'
END
ELSE
BEGIN
	PRINT 'Static data value 21304 - Fax already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

