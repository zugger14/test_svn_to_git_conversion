SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2172)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (2150, 2172, 'Forecast Data', 'Forecast Data', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 2172 - Forecast Data.'
END
ELSE
BEGIN
    PRINT 'Static data value 2172 - Forecast Data already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF