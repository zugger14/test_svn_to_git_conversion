SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2206)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (2206, 2200, 'Tungsten Number', 'Tungsten Number', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 2206 - Tungsten Number.'
END
ELSE
BEGIN
    PRINT 'Static data value 2206 - Tungsten Number already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF