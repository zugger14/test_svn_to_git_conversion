IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 40000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts, is_active)
	VALUES (40000, 'Weather Data Time Series', 0, 'Weather Data Time Series', 'farrms_admin', GETDATE(), 1)
 	PRINT 'Inserted static data type 40000 - Weather Data Time Series.'
END
ELSE
BEGIN
	UPDATE static_data_type
	SET [type_name] = 'Weather Data Time Series',
		[description] = 'Weather Data Time Series',
		internal = 0,
		is_active = 1
		WHERE [type_id] = 40000
	PRINT 'Updated static data type 40000 - Weather Data Time Series.'
END