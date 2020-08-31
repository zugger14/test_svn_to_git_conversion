IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 30800)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (30800, 'Accounting Type', 0, 'Accounting Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 30800 - Accounting Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 30800 - Accounting Type already EXISTS.'
END
