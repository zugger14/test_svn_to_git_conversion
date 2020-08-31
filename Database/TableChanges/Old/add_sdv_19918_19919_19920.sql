SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19918)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19918, 19900, 'Currency', 'Currency', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19918 - Currency.'
END
ELSE
BEGIN
	PRINT 'Static data value 19918 - Currency already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19919)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19919, 19900, 'Commodity', 'Commodity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19919 - Commodity.'
END
ELSE
BEGIN
	PRINT 'Static data value 19919 - Commodity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19920)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19920, 19900, 'Location', 'Location', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19920 - Location.'
END
ELSE
BEGIN
	PRINT 'Static data value 19920 - Location already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
