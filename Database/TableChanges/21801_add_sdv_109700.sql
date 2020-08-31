SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109700)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109700, 109700, 'Table', 'Table', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109700 - Table.'
END
ELSE
BEGIN
    PRINT 'Static data value 109700 - Table already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF