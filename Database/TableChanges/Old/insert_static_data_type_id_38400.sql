IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 38400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (38400, 'Contract Type', 1, 'Contract Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 38400 - Contract Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 38400 - Contract Type already EXISTS.'
END	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38400)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38400, 38400, 'Standard', 'Standard', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38400 - Standard.'
END
ELSE
BEGIN
	PRINT 'Static data value 38400 - Standard already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	

UPDATE static_data_type SET [type_name] = 'Contract Type', [description] = 'Contract Type' WHERE [type_id] = 38400
PRINT 'Updated Static data type 38400 - Contract Type.'

UPDATE static_data_value SET code = 'Standard', [description] = 'Standard' WHERE [value_id] = 38400
PRINT 'Updated Static value 38400 - Standard.'

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 38400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (38400, 'Contract Type', 1, 'Contract Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 38400 - Contract Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 38400 - Contract Type already EXISTS.'
END	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38401)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38401, 38400, 'Non-Standard', 'Non-Standard', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38401 - Non-Standard.'
END
ELSE
BEGIN
	PRINT 'Static data value 38401 - Non-Standard already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	
UPDATE static_data_type SET [type_name] = 'Contract Type', [description] = 'Contract Type' WHERE [type_id] = 38400
PRINT 'Updated Static data type 38400 - Contract Type.'	

UPDATE static_data_value SET code = 'Non-Standard', [description] = 'Non-Standard' WHERE [value_id] = 38401
PRINT 'Updated Static value 38401 - Non-Standard.'
