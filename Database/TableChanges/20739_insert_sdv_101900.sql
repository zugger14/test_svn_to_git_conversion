SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101900)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (101900, 101900, 'Transportation rate schedule', 'Transportation rate schedule', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101900 - Transportation rate schedule.'
END
ELSE
BEGIN
    PRINT 'Static data value 101900 - Transportation rate schedule already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

