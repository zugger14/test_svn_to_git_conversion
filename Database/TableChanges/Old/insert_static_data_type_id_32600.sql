IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 32600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (32600, 'Station Class', 0, 'Station Class', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 32600 - Station Class.'
END
ELSE
BEGIN
	PRINT 'Static data type 32600 - Station Class already EXISTS.'
END
