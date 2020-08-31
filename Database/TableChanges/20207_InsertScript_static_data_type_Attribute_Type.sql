IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 45900)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (45900, 'Attribute Type', 1, 'Attribute Type', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 45900 - Attribute Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 45900 - Attribute Type already EXISTS.'
END

UPDATE static_data_type
SET [type_name] = 'Attribute Type',
	[description] = 'Attribute Type',
	internal = 1
	WHERE [type_id] = 45900
PRINT 'Updated static data type 45900 - Attribute Type.'