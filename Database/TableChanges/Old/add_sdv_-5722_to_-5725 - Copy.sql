SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5722)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5722, 5500, 'Delivery Point', 'Delivery Point', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5722 - Delivery Point.'
END
ELSE
BEGIN
	PRINT 'Static data value -5722 - Delivery Point already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5723)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5723, 5500, 'Charge Type', 'Charge Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5723 - Charge Type.'
END
ELSE
BEGIN
	PRINT 'Static data value -5723 - Charge Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5724)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5724, 5500, 'Remit Reporting', 'Remit Reporting', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5724 - Remit Reporting.'
END
ELSE
BEGIN
	PRINT 'Static data value -5724 - Remit Reporting already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5725)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5725, 5500, 'Formula Row', 'Formula Row', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5725 - Formula Row.'
END
ELSE
BEGIN
	PRINT 'Static data value -5725 - Formula Row already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



UPDATE static_data_value SET code = 'Delivery Point', [description] = 'Delivery Point' WHERE [value_id] = -5722
PRINT 'Updated Static value -5722 - Delivery Point.'
UPDATE static_data_value SET code = 'Charge Type', [description] = 'Charge Type' WHERE [value_id] = -5723
PRINT 'Updated Static value -5723 - Charge Type.'
UPDATE static_data_value SET code = 'Remit Reporting', [description] = 'Remit Reporting' WHERE [value_id] = -5724
PRINT 'Updated Static value -5724 - Remit Reporting.'
UPDATE static_data_value SET code = 'Formula Row', [description] = 'Formula Row' WHERE [value_id] = -5725
PRINT 'Updated Static value -5725 - Formula Row.'