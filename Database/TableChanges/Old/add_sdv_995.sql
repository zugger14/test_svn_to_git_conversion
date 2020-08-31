
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 995)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (995, 978, '5Min', '5Min', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 995 - 5Min.'
END
ELSE
BEGIN
	PRINT 'Static data value 995 - 5Min already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF