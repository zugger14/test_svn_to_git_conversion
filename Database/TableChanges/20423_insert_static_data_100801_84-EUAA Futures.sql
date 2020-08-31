SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -100801)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-100801, 100800, '84', '84-EUAA Futures', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -100801 - 84.'
END
ELSE
BEGIN
    PRINT 'Static data value -100801 - 84 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
UPDATE static_data_value
    SET code = '84',
    [category_id] = ''
    WHERE [value_id] = -100801
PRINT 'Updated Static value -100801 - 84.'