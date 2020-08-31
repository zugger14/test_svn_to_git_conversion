SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112900)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112900, 112900, 'GL Posted', 'GL Posted', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112900 - GL Posted.'
END
ELSE
BEGIN
    PRINT 'Static data value 112900 - GL Posted already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF