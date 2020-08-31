IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 43700)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts, is_active)
	VALUES (43700, 'Commodity Form', 0, 'Commodity Form', 'farrms_admin', GETDATE(), 1)
	PRINT 'Inserted static data type 43700 - Commodity Form.'
END
ELSE
BEGIN
	PRINT 'Static data type 43700 - Commodity Form already EXISTS.'
END