IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 43500)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (43500, 'Offset Method', 1, 'Offset Method', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 43500 - Offset Method.'
END
ELSE
BEGIN
	PRINT 'Static data type 43500 - Offset Method already EXISTS.'
END