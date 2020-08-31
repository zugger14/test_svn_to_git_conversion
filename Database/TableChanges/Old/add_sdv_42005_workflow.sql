SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42005)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (42005, 42000, 'Workflow', 'Workflow', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 42005 - Workflow.'
END
ELSE
BEGIN
	PRINT 'Static data value 42005 - Workflow already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
