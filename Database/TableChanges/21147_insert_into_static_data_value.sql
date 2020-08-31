SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4075)
BEGIN 
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (4075, 4075, 'Cum Dollar Test', 'Cum Dollar Test', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 4075 - Cum Dollar Test.'
END 
ELSE
BEGIN
    PRINT 'Static data value 4075 - Cum Dollar Test already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF