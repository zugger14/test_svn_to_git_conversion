SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101600)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (101600, 101600, 'English', 'English', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101600 - English.'
END
ELSE
BEGIN
    PRINT 'Static data value 101600 - English already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 101602)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (101600, 101602, 'Ukrainian', 'Ukrainian', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 101602 - Ukrainian.'
END
ELSE
BEGIN
    PRINT 'Static data value 101602 - Ukrainian already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF