SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105400)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105400, 105400, 'Approved', 'Approved', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105400 - Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 105400 - Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105401)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105401, 105400, 'On Hold', 'On Hold', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105401 - On Hold.'
END
ELSE
BEGIN
    PRINT 'Static data value 105401 - On Hold already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF