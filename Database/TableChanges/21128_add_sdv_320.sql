SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 320)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (320, 300, 'Effectivess Testing Not Required', 'Effectivess Testing Not Required', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 320 - Effectivess Testing Not Required.'
END 
ELSE
BEGIN
    PRINT 'Static data value 320 - Effectivess Testing Not Required already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF