IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE type_id = 17800)
BEGIN
	
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (17800, 'Email Module Type', 1, 'Email Module Type', 'farrms_admin', GETDATE())
	
	PRINT 'Internal static type 17800 - Email Module Type added.'
END
ELSE
BEGIN
	PRINT 'Internal static type 17800 - Email Module Type added.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17800)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17800, 17800, 'Trade Ticket', 'Trade Ticket', 'farrms_admin', GETDATE())
	
	SET IDENTITY_INSERT static_data_value OFF
	
	PRINT 'Internal static data 17800 - Trade Ticket added.'
END
ELSE
BEGIN
	PRINT 'Internal static data 17800 - Trade Ticket already exists.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17801)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (17801, 17800, 'Job Failure Notification', 'Job Failure Notification', 'farrms_admin', GETDATE())
	
	SET IDENTITY_INSERT static_data_value OFF
	
	PRINT 'Internal static data 17801 - Job Failure Notification added.'
END
ELSE
BEGIN
	PRINT 'Internal static data 17801 - Job Failure Notification already exists.'
END