SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19922)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (19900, 19922, 'Counterparty Contract', 'Counterparty Contract', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 19922 - Counterparty Contract.'
END
ELSE
BEGIN
    PRINT 'Static data value 19922 - Counterparty Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            