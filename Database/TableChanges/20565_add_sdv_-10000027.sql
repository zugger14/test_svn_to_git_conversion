SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000027)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000027, 5500, 'Product Classification Type', 'Product Classification Type', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000027 - Product Classification Type.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000027 - Product Classification Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF