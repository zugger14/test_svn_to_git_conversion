IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 27200)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (27200, 'Match Status', 1, 'Match Status', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 27200 - Match Status.'
END
ELSE
BEGIN
	PRINT 'Static data type 27200 - Match Status already EXISTS.'
END