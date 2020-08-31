IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [code] = 'Base Load')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (10018, 'Base Load', 'Base Load', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - Base Load.'
END
ELSE
BEGIN
	PRINT 'Static data value - Base Load already EXISTS.'
END
