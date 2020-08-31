IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 105000)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (105000, 'Reservoir ', 0, '', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 105000 - Reservoir .'
END
ELSE
BEGIN
	PRINT 'Static data type 105000 - Reservoir  already EXISTS.'
END