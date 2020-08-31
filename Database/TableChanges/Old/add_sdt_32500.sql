IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 32500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (32500, 'Route Name', 0, 'Route Name', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 32500 - Route Name.'
END
ELSE
BEGIN
	PRINT 'Static data type 32500 - Route Name already EXISTS.'
END