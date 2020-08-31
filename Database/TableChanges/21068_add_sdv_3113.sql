SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 3113)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (3113, 3100, 'RO', 'RO', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 3113 - RO.'
END
ELSE
BEGIN
    PRINT 'Static data value 3113 - RO already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF