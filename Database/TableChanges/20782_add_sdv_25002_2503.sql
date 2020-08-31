SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25003)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25003, 25000, 'Actual', 'Actual', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25003 - Actual.'
END
ELSE
BEGIN
    PRINT 'Static data value 25003 - Actual already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25002)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25002, 25000, 'Forecast', 'Forecast', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25002 - Forecast.'
END
ELSE
BEGIN
    PRINT 'Static data value 25002 - Forecast already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF