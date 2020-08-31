SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39405)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39405, 39400, 'Execution', 'Execution', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39405 - Execution.'
END
ELSE
BEGIN
	PRINT 'Static data value 39405 - Execution already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value SET code = 'Execution', [description] = 'Execution' WHERE [value_id] = 39405
PRINT 'Updated Static value 39405 - Execution.'
