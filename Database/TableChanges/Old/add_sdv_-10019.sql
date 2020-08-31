SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10019)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-10019, 10019, 'Commodity Charge', 'Commodity Charge', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 12504 - Commodity Charge.'
END
ELSE
BEGIN
	PRINT 'Static data value -10019 - Commodity Charge already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
