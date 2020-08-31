SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106504)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (106500, 106504, 'Import Filter View', 'Import Filter View', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106504 - Import Filter View.'
END
ELSE
BEGIN
    PRINT 'Static data value 106504 - Import Filter View already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            