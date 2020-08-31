
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 44800)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (44800, 'Generator Configuration', 0, 'Generator Configuration', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 44800 - Generator Configuration.'
END
ELSE
BEGIN

	UPDATE static_data_type
	SET [type_name] = 'Generator Configuration',
		[description] = 'Generator Configuration',
		internal = 0
		WHERE [type_id] = 44800
	PRINT 'Updated static data type 44800 - Generator Configuration.'

END