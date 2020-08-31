IF NOT EXISTS(SELECT * FROM static_data_type WHERE [type_id] = 37800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (37800, 'Event Type', 0, 'Event Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 37800 - Event Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 37800 - Event Type already EXISTS.'
END
