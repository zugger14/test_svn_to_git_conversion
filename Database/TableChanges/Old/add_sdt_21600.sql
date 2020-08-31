-- static data type
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 21600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (21600, 'Fee Type', 1, 'Fee Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 21600 - Action Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 21600 - Fee Type already EXISTS.'
END

