SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 55)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (55, 25, 'Counterparty Enhancement', 'Counterparty Enhancement', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 55 - Counterparty Enhancement.'
END
ELSE
BEGIN
    PRINT 'Static data value 55 - Counterparty Enhancement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF