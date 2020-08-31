IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 39000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (39000, 'Series Type', 1, 'Series Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 39000 - Series Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 39000 - Series Type already EXISTS.'
END
