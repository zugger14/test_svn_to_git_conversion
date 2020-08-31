IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 39600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (39600, 'PSE', 0, 'PSE', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 39600 - PSE.'
END
ELSE
BEGIN
	PRINT 'Static data type 39600 - PSE already EXISTS.'
END
