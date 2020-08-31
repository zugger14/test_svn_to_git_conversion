IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 46900)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (46900, 'Underlying Options', 1, 'Underlying Options', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 46900 - Underlying Options.'
END
ELSE
BEGIN
	PRINT 'Static data type 46900 - Underlying Options already EXISTS.'
END