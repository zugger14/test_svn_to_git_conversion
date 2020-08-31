IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 32200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (32200, 'Contact Type', 0, 'Contact Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 32200 - Contact Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 32200 - Contact Type already EXISTS.'
END
