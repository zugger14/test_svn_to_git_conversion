SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1618)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (1600, 1618, 'Capacity Based', 'Capacity Based', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 1618 - Capacity Based.'
END
ELSE
BEGIN
    PRINT 'Static data value 1618 - Capacity Based already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF