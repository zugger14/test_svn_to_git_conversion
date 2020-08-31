SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -913)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-913, 800, 'ABS', 'Returns absolute vaue.', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -913 - ABS.'
END
ELSE
BEGIN
	PRINT 'Static data value -913 - ABS already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -913) 
BEGIN
	INSERT INTO map_function_category(category_id, function_id)
	VALUES(27400, -913)
END
ELSE
	PRINT 'Already Mapped'

