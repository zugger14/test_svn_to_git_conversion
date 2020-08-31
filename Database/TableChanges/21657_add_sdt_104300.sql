IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 104300)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (104300, 'Data Types', 1, 'Data Types', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 104300 - Data Types.'
END
ELSE
BEGIN
	PRINT 'Static data type 104300 - Data Types already EXISTS.'
END