IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 43000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (43000, 'Document Type User', 0, 'Document Type User', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 43000 - Document Type User.'
END
ELSE
BEGIN
	PRINT 'Static data type 43000 - Document Type User already EXISTS.'
END
