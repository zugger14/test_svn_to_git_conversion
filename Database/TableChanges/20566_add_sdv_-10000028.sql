SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000028)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000028, 5500, 'Product Classification', 'Product Classification', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000028 - Product Classification.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000028 - Product Classification already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF