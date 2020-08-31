IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 106000)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (106000, 'Qualitative Rating', 0, 'Qualitative Rating', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 106000 - Qualitative Rating.'
END
ELSE
BEGIN
	PRINT 'Static data type 106000 - Qualitative Rating already EXISTS.'
END