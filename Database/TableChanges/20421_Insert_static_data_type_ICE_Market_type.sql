IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 100800)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (100800, 'ICE Market Type', 0, 'Market Type', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 100800 - ICE Market Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 100800 - ICE Market Type already EXISTS.'
END

UPDATE static_data_type
SET [type_name] = 'ICE Market Type',
	[description] = 'Market Type',
	[internal] = 0, 
	[is_active] = 1
	WHERE [type_id] = 100800
PRINT 'Updated static data type 100800 - ICE Market Type.'