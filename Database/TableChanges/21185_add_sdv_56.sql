SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 56)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (56, 25, 'Counterparty Contract Type', 'Counterparty Contract Type', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 56 - Counterparty Contract Type.'
END
ELSE
BEGIN
    PRINT 'Static data value 56 - Counterparty Contract Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF