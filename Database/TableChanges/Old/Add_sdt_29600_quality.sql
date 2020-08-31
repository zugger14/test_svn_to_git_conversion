IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 29600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (29600, 'Quality', 0, 'Quality', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 29600 - Quality.'
END
ELSE
BEGIN
	PRINT 'Static data type 29600 - Quality already EXISTS.'
END