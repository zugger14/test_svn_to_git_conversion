SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101902)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (101900, 101902, 'Energy TAX', 'Energy TAX', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101902 - Energy TAX.'
END
ELSE
BEGIN
    PRINT 'Static data value 101902 - Energy TAX already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101903)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (101900, 101903, 'VAT', 'VAT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101903 - VAT.'
END
ELSE
BEGIN
    PRINT 'Static data value 101903 - VAT already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


