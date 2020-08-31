IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 5500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (5500, 'User Defined Fields', 1, 'User Defined Fields', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 5500 - User Defined Fields.'
END
ELSE
BEGIN
	PRINT 'Static data type 5500 - User Defined Fields already EXISTS.'
END
