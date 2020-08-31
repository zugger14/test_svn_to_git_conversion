/*
 * Static data type : Export Report Format
 */
 
 IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 27500)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (27500, 'Export Report Format', 1, 'Export Report Format', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 27500 - Export Report Format.'
END
ELSE
BEGIN
	PRINT 'Static data type 27500 - Export Report Format already EXISTS.'
END
