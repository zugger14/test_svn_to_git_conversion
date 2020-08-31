SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45506)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45506, 45500, 'European Monte Carlo Spread', 'European Monte Carlo Spread', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45506 - European Monte Carlo Spread.'
END
ELSE
BEGIN
    PRINT 'Static data value 45506 - European Monte Carlo Spread already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

UPDATE static_data_value
    SET code = 'European Monte Carlo Spread',
    [category_id] = ''
    WHERE [value_id] = 45506
PRINT 'Updated Static value 45506 - European Monte Carlo Spread.'