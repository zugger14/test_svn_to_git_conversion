SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5579)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5579, 5500, 'Price', 'Price', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5579 - Price.'
END
ELSE
BEGIN
	PRINT 'Static data value -5579 - Price already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5580)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5580, 5500, 'Price_OFF', 'Price_OFF', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5580 - Price_OFF.'
END
ELSE
BEGIN
	PRINT 'Static data value -5580 - Price_OFF already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5581)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5581, 5500, 'Customer', 'Customer', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5581 - Customer.'
END
ELSE
BEGIN
	PRINT 'Static data value -5581 - Customer already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF