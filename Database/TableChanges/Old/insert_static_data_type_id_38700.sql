IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 38700)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (38700, ' Calendar Type', 1, ' Calendar Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 38700 - Calendar Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 38700 -  Calendar Type already EXISTS.'
END
