IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 32000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (32000, 'Nom Group Priority', 0, 'Nom Group Priority', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 32000 - Nom Group Priority.'
END
ELSE
BEGIN
	PRINT 'Static data type 32000 - Nom Group Priority already EXISTS.'
END