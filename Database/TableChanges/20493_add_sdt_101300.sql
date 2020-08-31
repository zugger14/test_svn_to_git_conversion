IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 101300)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], [internal], [description], [is_active], create_user, create_ts)
	VALUES (101300, 'Environment Product', 0, 'Environment Product', 1, 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 101300 - Environment Product.'
END
ELSE
BEGIN
	PRINT 'Static data type 101300 - Environment Product already EXISTS.'
END