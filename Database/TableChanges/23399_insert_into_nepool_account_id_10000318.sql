SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10000318)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (2200, 10000318, 'Nepool Account ID', 'Nepool Account ID', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10000318 - Nepool Account ID.'
END
ELSE
BEGIN
    PRINT 'Static data value 10000318 - Nepool Account ID already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            