IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 45400)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (45400, 'Accounting', 1, 'Accounting', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 45400 - Accounting.'
END
ELSE
BEGIN
	PRINT 'Static data type 45400 - Accounting already EXISTS.'
END