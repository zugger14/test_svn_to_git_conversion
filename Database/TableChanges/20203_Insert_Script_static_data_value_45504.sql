SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45504)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45504, 45500, 'Kirk Approximation', 'Kirk Approximation', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45504 - Kirk Approximation.'
END
ELSE
BEGIN
    PRINT 'Static data value 45504 - Kirk Approximation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



UPDATE static_data_value
    SET code = 'Kirk Approximation',
    [category_id] = ''
    WHERE [value_id] = 45504
PRINT 'Updated Static value 45504 - Kirk Approximation.'