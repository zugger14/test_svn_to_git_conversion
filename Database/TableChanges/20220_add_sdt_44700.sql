IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 44700)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (44700, 'Submission Type', 1, 'Submission Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 44700 - Submission Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 44700 - Submission Type already EXISTS.'
END