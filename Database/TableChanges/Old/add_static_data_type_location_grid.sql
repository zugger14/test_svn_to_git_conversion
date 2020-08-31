IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (18000, 'Location Grid', 0, 'Location Grid', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 18000 - Location Grid.'
END
ELSE
BEGIN
	PRINT 'Static data type 18000 - Location Grid already EXISTS.'
END	
