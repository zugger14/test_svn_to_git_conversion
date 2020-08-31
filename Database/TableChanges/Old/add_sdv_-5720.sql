SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5720)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5720, 5500, 'Product ID', 'Product ID', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5720 - Product ID.'
END
ELSE
BEGIN
	PRINT 'Static data value -5720 - Product ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
