IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 10016)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (10016, 'State', 0, 'State', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 10016 - State.'
END
ELSE
BEGIN
	PRINT 'Static data type 10016 - State already EXISTS.'
END
