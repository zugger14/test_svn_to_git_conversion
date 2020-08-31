IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 40300)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (40300, 'Governing Law', 0, 'Governing Law', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 40300 - Governing Law.'
END
ELSE
BEGIN
	PRINT 'Static data type 40300 - Governing Law already EXISTS.'
END