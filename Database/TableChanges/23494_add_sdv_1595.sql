SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1595)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (1580, 1595, 'Notional Value', 'Notional Value', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 1595 - Notional Value.'
END
ELSE
BEGIN
    PRINT 'Static data value 1595 - Notional Value already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF