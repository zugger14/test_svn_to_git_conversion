SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39001)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39001, 39000, 'Contract Price', 'Contract Price', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39001 - Contract Price.'
END
ELSE
BEGIN
	PRINT 'Static data value 39001 - Contract Price already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 39002)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (39002, 39000, 'Weather Data', 'Weather Data', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 39002 - Weather Data.'
END
ELSE
BEGIN
	PRINT 'Static data value 39002 - Weather Data already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
