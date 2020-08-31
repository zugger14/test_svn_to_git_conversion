SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 38)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (38, 25, 'Invoice', 'Invoice', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 38 - Invoice.'
END
ELSE
BEGIN
	PRINT 'Static data value 38 - Invoice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

 
