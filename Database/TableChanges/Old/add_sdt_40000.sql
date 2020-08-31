IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 40000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (40000, 'Weather Data Time Series', 0, 'Weather Data Time Series', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 40000 - Weather Data Time Series.'
END
ELSE
BEGIN
	PRINT 'Static data type 40000 - Weather Data Time Series already EXISTS.'
END