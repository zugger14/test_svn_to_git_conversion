SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110200)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110200, 110200, 'Copy Proxy Position', 'Copy Proxy Position', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110200 - Copy Proxy Position.'
END
ELSE
BEGIN
    PRINT 'Static data value 110200 - Copy Proxy Position already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110201)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110200, 110201, 'Aggregate Proxy Position', 'Aggregate Proxy Position', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110201 - Aggregate Proxy Position.'
END
ELSE
BEGIN
    PRINT 'Static data value 110201 - Aggregate Proxy Position already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            