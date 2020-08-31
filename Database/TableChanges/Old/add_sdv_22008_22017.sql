SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22008)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22008, 22000, 'Maintain Defination Currency Detail', 'Maintain Defination Currency Detail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22008 - Maintain Defination Currency Detail.'
END
ELSE
BEGIN
	PRINT 'Static data value 22008 - Maintain Defination Currency Detail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22009)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22009, 22000, 'Maintain Defination Commodity', 'Maintain Defination Commodity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22009 - Maintain Defination Commodity.'
END
ELSE
BEGIN
	PRINT 'Static data value 22009 - Maintain Defination Commodity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22010)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22010, 22000, 'Maintain Defination Trader', 'Maintain Defination Trader', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22010 - Maintain Defination Trader.'
END
ELSE
BEGIN
	PRINT 'Static data value 22010 - Maintain Defination Trader already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22011)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22011, 22000, 'Maintain Defination UOM', 'Maintain Defination UOM', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22011 - Maintain Defination UOM.'
END
ELSE
BEGIN
	PRINT 'Static data value 22011 - Maintain Defination UOM already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22012)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22012, 22000, 'Maintain Defination Product', 'Maintain Defination Product', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22012 - Maintain Defination Product.'
END
ELSE
BEGIN
	PRINT 'Static data value 22012 - Maintain Defination Product already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22013)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22013, 22000, 'Maintain Internal Desk Detail', 'Maintain Internal Desk Detail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22013 - Maintain Internal Desk Detail.'
END
ELSE
BEGIN
	PRINT 'Static data value 22013 - Maintain Internal Desk Detail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22014)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22014, 22000, 'Maintain Defination Book Attribute', 'Maintain Defination Book Attribute', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22014 - Maintain Defination Book Attribute.'
END
ELSE
BEGIN
	PRINT 'Static data value 22014 - Maintain Defination Book Attribute EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22015)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22015, 22000, 'Maintain Defination Deal Type Detail', 'Maintain Defination Deal Type Detail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22014 - Maintain Defination Deal Type Detail.'
END
ELSE
BEGIN
	PRINT 'Static data value 22015 - Maintain Defination Deal Type Detail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22016)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22016, 22000, 'Maintain Defination Portfolio Detail', 'Maintain Defination Portfolio Detail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22016 - Maintain Defination Portfolio Detail.'
END
ELSE
BEGIN
	PRINT 'Static data value 22016 - Maintain Defination Portfolio Detail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22017)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22017, 22000, 'Maintain Definition Legal Entity Detail', 'Maintain Definition Legal Entity Detail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22017 - Maintain Definition Legal Entity Detail.'
END
ELSE
BEGIN
	PRINT 'Static data value 22017 - Maintain Definition Legal Entity Detail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF