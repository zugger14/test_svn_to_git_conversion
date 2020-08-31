IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 27400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (27400, 'Function Category', 1, 'Function Category', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 27400 - Function Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 27400 - Function Category already EXISTS.'
END