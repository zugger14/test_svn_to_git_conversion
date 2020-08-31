IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 5)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (5, 1, 'Job Notification Group', 'Job Notification Group', 'farrms_admin', GETDATE())
	
	SET IDENTITY_INSERT static_data_value OFF
	
	PRINT 'Internal static data 5 - Job Notification Group added.'
END
ELSE
BEGIN
	PRINT 'Internal static data 5 - Job Notification Group already exists.'
END