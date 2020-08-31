IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 104600)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (104600, 'Deal UDF Group', 0, 'Deal UDF Group', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 104600 - Deal UDF Group.'
END
ELSE
BEGIN
	PRINT 'Static data type 104600 - Deal UDF Group already EXISTS.'
END