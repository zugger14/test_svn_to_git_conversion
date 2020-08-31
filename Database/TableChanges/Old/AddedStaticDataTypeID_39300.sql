IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 39300)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (39300, 'Rounding', 0, 'Rounding', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 39300 - Rounding.'
END
ELSE
BEGIN
	PRINT 'Static data type 39300 - Rounding already EXISTS.'
END
