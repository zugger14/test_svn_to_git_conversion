IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 101900)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (101900, 'Udf Category', 1, 'Udf Category', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 101900 - Udf Category.'
END
ELSE
BEGIN
	PRINT 'Static data type 101900 - Udf Category already EXISTS.'
END