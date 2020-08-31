SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 107302)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (107300, 107302, 'Price', 'Price', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 107302 - Price.'
END
ELSE
BEGIN
    PRINT 'Static data value 107302 - Price already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF