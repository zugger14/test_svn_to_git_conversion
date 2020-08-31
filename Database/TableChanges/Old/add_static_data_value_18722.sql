SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18722)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18722, 18700, 'Option Premium', 'Option Premium', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18722 - Option Premium.'
END
ELSE
BEGIN
	PRINT 'Static data value 18722 - Option Premium already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
