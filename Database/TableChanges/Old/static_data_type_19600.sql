IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19600)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19600, 'ST Forecast Group', 0, 'ST Forecast Group', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19600 - ST Forecast Group.'
END
ELSE
BEGIN
	PRINT 'Static data type 19600 - ST Forecast Group already EXISTS.'
END
