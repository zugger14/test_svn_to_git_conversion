SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000324)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (32200, -10000324, 'Netting', 'Netting', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000324 - Netting.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000324 - Netting already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF  


