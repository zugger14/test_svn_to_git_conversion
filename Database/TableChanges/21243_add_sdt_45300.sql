IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 45300)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (45300, 'Ownership Type', 1, 'Ownership Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 45300 - Ownership Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 45300 - Ownership Type already EXISTS.'
END