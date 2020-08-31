SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18732)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (18732, 18700, 'Lump Sum Fixed', 'Lump Sum Fixed', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 18732 - Lump Sum Fixed.'
END
ELSE
BEGIN
    PRINT 'Static data value 18732 - Lump Sum Fixed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'Lump Sum Fixed',
    [category_id] = ''
    WHERE [value_id] = 18732
PRINT 'Updated Static value 18732 - Lump Sum Fixed.'