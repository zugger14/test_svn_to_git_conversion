IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 45700)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts, is_active)
	VALUES (45700, 'Incident Type', 0, 'Incident Type', 'farrms_admin', GETDATE(), 1)
	PRINT 'Inserted static data type 45700 - Incident Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 45700 - Incident Type already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 45800)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts, is_active)
	VALUES (45800, 'Incident Status', 0, 'Incident Status', 'farrms_admin', GETDATE(), 1)
	PRINT 'Inserted static data type 45800 - Incident Status.'
END
ELSE
BEGIN
	PRINT 'Static data type 45800 - Incident Status already EXISTS.'
END