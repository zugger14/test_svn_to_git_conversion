IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 46700)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts, is_active)
	VALUES (46700, 'Pricing Type', 1, 'Pricing Type', 'farrms_admin', GETDATE(), 1)
	PRINT 'Inserted static data type 46700 - Pricing Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 46700 - Pricing Type already EXISTS.'
END