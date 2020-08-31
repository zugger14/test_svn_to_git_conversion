IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 40500)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (40500, 'Remarks', 0, 'Remarks', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 40500 - Remarks.'
END
ELSE
BEGIN
	PRINT 'Static data type 40500 - Remarks already EXISTS.'
END