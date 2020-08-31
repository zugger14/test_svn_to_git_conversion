SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 301995)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (301995, 10020, 'Market Place', 'Market Place', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 301995 - Market Place.'
END
ELSE
BEGIN
	PRINT 'Static data value 301995 - Market Place already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF