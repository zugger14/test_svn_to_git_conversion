SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18744)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (18700, 18744, 'VAT', 'VAT', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18744 - VAT.'
END
ELSE
BEGIN
    PRINT 'Static data value 18744 - VAT already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF