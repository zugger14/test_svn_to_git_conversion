SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1596)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (1580, 1596, 'Notional Value Limit', 'Notional Value Limit', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 1596 - Notional Value Limit.'
END
ELSE
BEGIN
    PRINT 'Static data value 1596 - Notional Value Limit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF