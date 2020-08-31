
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 20400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description],create_user, create_ts)
	VALUES (20400, 'Meter Allocation Type', 1, 'Meter Allocation Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 20400 - Meter Allocation Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 20400 - Meter Allocation Type already EXISTS.'
END	SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20401)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20401, 20400, 'Contract Volume', 'Contract Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20401 - Contract Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value 20401 - Contract Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	UPDATE static_data_type SET [type_name] = 'Meter Allocation Type', [description] = 'Meter Allocation Type' WHERE [type_id] = 20400
PRINT 'Updated Static data type 20400 - Meter Allocation Type.'	UPDATE static_data_value SET code = 'Contract Volume', [description] = 'Contract Volume' WHERE [value_id] = 20401
PRINT 'Updated Static value 20401 - Contract Volume.'
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20400)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20400, 20400, 'Standard Yearly Volume', 'Standard Yearly Volume', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20400 - Standard Yearly Volume.'
END
ELSE
BEGIN
	PRINT 'Static data value 20400 - Standard Yearly Volume already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	UPDATE static_data_type SET [type_name] = 'Meter Allocation Type', [description] = 'Meter Allocation Type' WHERE [type_id] = 20400
PRINT 'Updated Static data type 20400 - Meter Allocation Type.'	UPDATE static_data_value SET code = 'Standard Yearly Volume', [description] = 'Standard Yearly Volume' WHERE [value_id] = 20400
PRINT 'Updated Static value 20400 - Standard Yearly Volume.'
