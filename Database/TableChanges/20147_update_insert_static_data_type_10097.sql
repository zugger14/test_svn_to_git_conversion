IF EXISTS(SELECT 1 FROM static_data_type sdt WHERE sdt.[type_id] = 10097)
BEGIN
	SET NOCOUNT ON;  
	UPDATE dbo.static_data_type
	SET TYPE_NAME = 'Internal Rating',
	DESCRIPTION = 'Internal Rating'
	WHERE [type_id] = 10097
	
	PRINT 'Static data type ''10097'' updated.'
END 
ELSE
BEGIN
	SET NOCOUNT ON;	
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (10097, 'Internal Rating', 0, 'Internal Rating', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 10097 - Internal Rating.'
	
	PRINT 'Static data type ''10097'' inserted.'
END