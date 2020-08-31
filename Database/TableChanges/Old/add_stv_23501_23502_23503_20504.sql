SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23501)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (23501, 23500, 'Static Data', ' Static Data', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 23501 - Static Data.'
END
ELSE
BEGIN
    PRINT 'Static data value 23501 - Static Data already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23502)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (23502, 23500, 'Deal', ' Deal', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 23502 - Deal.'
END
ELSE
BEGIN
    PRINT 'Static data value 23502 - Deal already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23503)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (23503, 23500, 'Time Series', ' Time Series', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 23503 - Time Series.'
END
ELSE
BEGIN
    PRINT 'Static data value 23503 - Time Series already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 23504)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (23504, 23500, 'User Defined', ' User Defined', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 23504 - User Defined.'
END
ELSE
BEGIN
    PRINT 'Static data value 23504 - User Defined already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF