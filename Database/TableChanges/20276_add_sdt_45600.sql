IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 45600)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (45600, 'Override Type', 1, 'Override Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 45600 - Override Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 45600 - Override Type already EXISTS.'
END