SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45902)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45902, 45900, 'a', 'Approximation', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45902 - a.'
END
ELSE
BEGIN
    PRINT 'Static data value 45902 - a already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'a',
    [category_id] = ''
    WHERE [value_id] = 45902
PRINT 'Updated Static value 45902 - a.'