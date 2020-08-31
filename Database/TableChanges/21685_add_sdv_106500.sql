IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 106500)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (106500, 'User defined Views', 1, '', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 106500 - User defined Views.'
END
ELSE
BEGIN
	PRINT 'Static data type 106500 - User defined Views already EXISTS.'
END