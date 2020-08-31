IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 21500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (21500, 'Contract Document Type', 1, 'Contract Document Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 21500 - Contract Document Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 21500 - Contract Document Type already EXISTS.'
END
