IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 31400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (31400, 'Priority', 0, 'Priority', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 31400 - Priority.'
END
ELSE
BEGIN
	PRINT 'Static data type 31400 - Priority already EXISTS.'
END
