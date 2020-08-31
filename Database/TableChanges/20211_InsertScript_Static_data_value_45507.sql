SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45507)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45507, 45500, 'American Monte Carlo Spread', 'American Monte Carlo Spread', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45507 - American Monte Carlo Spread.'
END
ELSE
BEGIN
    PRINT 'Static data value 45507 - American Monte Carlo Spread already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'American Monte Carlo Spread',
    [category_id] = ''
    WHERE [value_id] = 45507
PRINT 'Updated Static value 45507 - American Monte Carlo Spread.'