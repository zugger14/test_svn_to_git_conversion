IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 40100)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (40100, 'Deal Groups', 0, 'Deal Groups', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 40100 - Deal Groups.'
END
ELSE
BEGIN
	PRINT 'Static data type 40100 - Deal Groups already EXISTS.'
END