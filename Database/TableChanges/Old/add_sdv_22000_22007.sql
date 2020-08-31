SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22000)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22000, 22000, 'Maintain Contract', 'Maintain Contract', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22000 - Maintain Contract.'
END
ELSE
BEGIN
	PRINT 'Static data value 22000 - Maintain Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22001, 22000, 'Maintain Counterparty Detail', 'Maintain Counterparty Detail', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22001 - Maintain Counterparty Detail.'
END
ELSE
BEGIN
	PRINT 'Static data value 22001 - Maintain Counterparty Detail already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22002)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22002, 22000, 'Credit info', 'Credit info', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22002 - Credit info.'
END
ELSE
BEGIN
	PRINT 'Static data value 22002 - Credit info already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22003)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22003, 22000, 'Setup Location', 'Setup Location', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22003 - Setup Location.'
END
ELSE
BEGIN
	PRINT 'Static data value 22003 - Setup Location already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22004)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22004, 22000, 'Setup Profile', 'Setup Profile', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22004 - Setup Profile.'
END
ELSE
BEGIN
	PRINT 'Static data value 22004 - Setup Profile already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22005)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22005, 22000, 'Setup Price Curves', 'Setup Price Curves', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22005 - Setup Price Curves.'
END
ELSE
BEGIN
	PRINT 'Static data value 22005 - Setup Price Curves already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22006)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22006, 22000, 'Maintain Source generator', 'Maintain Source generator', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22006 - Maintain Source generator.'
END
ELSE
BEGIN
	PRINT 'Static data value 22006 - Maintain Source generator already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 22007)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (22007, 22000, 'Map GL Codes', 'Map GL Codes', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 22007 - Map GL Codes.'
END
ELSE
BEGIN
	PRINT 'Static data value 22007 - Map GL Codes already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF







