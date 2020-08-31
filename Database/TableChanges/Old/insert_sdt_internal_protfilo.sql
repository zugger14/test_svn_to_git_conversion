IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 39800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (39800, 'Internal Portfolio', 0, 'Internal Portfolio', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 39800 - Internal Portfolio.'
END
ELSE
BEGIN
	PRINT 'Static data type 39800 - Internal Portfolio already EXISTS.'
END
