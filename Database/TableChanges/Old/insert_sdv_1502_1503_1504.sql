SET IDENTITY_INSERT static_data_value ON

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1502)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1502, 1500, '99%', '99%', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1502 - 99%.'
END
ELSE
BEGIN
	PRINT 'Static data value 1502 - 99% already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1503)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1503, 1500, '90%', '90%', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1503 - 90%.'
END
ELSE
BEGIN
	PRINT 'Static data value 1503 - 90% already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1504)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1504, 1500, '95%', '95%', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1504 - 95%.'
END
ELSE
BEGIN
	PRINT 'Static data value 1504 - 95% already EXISTS.'
END

SET IDENTITY_INSERT static_data_value OFF
