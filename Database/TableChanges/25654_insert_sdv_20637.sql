SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20637)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20600, 20637, 'Netting Statement', 'Netting Statement', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20637 - Netting Statement.'
END
ELSE
BEGIN
    PRINT 'Static data value 20637 - Netting Statement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            