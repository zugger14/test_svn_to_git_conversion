SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2229)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (2229, 2200, 'Alias', 'Alias', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 2229 - Alias.'
END
ELSE
BEGIN
    PRINT 'Static data value 2229 - Alias already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF