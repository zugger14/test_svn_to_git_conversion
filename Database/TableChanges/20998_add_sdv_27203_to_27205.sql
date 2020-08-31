SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27203)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (27203, 27200, 'New', 'New', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 27203 - New.'
END
ELSE
BEGIN
    PRINT 'Static data value 27203 - New already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27204)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (27204, 27200, 'Modified', 'Modified', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 27204 - Modified.'
END
ELSE
BEGIN
    PRINT 'Static data value 27204 - Modified already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 27205)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (27205, 27200, 'Approved', 'Approved', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 27205 - Approved.'
END
ELSE
BEGIN
    PRINT 'Static data value 27205 - Approved already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF