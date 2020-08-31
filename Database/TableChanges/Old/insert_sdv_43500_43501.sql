SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 43500)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (43500, 43500, 'Cash Apply', ' Cash Apply', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 43500 - Cash Apply.'
END
ELSE
BEGIN
    PRINT 'Static data value 43500 - Cash Apply already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 43501)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (43501, 43500, 'Payment Date', ' Payment Date', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 43501 - Payment Date.'
END
ELSE
BEGIN
    PRINT 'Static data value 43501 - Payment Date already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


