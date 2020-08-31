IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 46000)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (46000, 'Algorithm', 1, 'Algorithm', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 46000 - Algorithm.'
END
ELSE
BEGIN
	PRINT 'Static data type 46000 - Algorithm already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 46100)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (46100, 'Error Function', 1, 'Error Function', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 46100 - Error Function.'
END
ELSE
BEGIN
	PRINT 'Static data type 46100 - Error Function already EXISTS.'
END