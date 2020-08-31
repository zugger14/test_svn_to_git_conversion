IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 44300)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description],is_active, create_user, create_ts)
	VALUES (44300, 'UOM Type ', 1, 'UOM Type', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 44300 - UOM Type .'
END
ELSE
BEGIN
	PRINT 'Static data type 44300 - UOM Type  already EXISTS.'
END

