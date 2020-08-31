IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 32400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (32400, 'Rounding Method', 0, 'Rounding Method', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 32400 - Rounding Method.'
END
ELSE
BEGIN
	PRINT 'Static data type 32400 - Rounding Method already EXISTS.'
END
