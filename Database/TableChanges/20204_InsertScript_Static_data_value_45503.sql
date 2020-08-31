SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45503)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45503, 45500, 'American Monte Carlo', 'American Monte Carlo', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45503 - American Monte Carlo.'
END
ELSE
BEGIN
    PRINT 'Static data value 45503 - American Monte Carlo already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'American Monte Carlo',
    [category_id] = ''
    WHERE [value_id] = 45503
PRINT 'Updated Static value 45503 - American Monte Carlo.'