SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10000022)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10000022, 5500, 'Special Condition', 'Special Condition', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10000022 - Special Condition.'
END
ELSE
BEGIN
    PRINT 'Static data value -10000022 - Special Condition already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'Special Condition',
    [category_id] = ''
    WHERE [value_id] = -10000022
PRINT 'Updated Static value -10000022 - Special Condition.'