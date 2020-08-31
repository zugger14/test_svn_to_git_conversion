/********************Compliance**************************/
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25005)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25005, 25000, 'Compliance', 'Compliance', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25005 - Compliance.'
END
ELSE
BEGIN
    PRINT 'Static data value 25005 - Compliance already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

/**************Transferred*********************************/
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25006)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25006, 25000, 'Transferred', 'Transferred', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25006 - Transferred.'
END
ELSE
BEGIN
    PRINT 'Static data value 25006 - Transferred already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

/***************Generated*************************/
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25007)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25007, 25000, 'Generated', 'Generated', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25007 - Generated.'
END
ELSE
BEGIN
    PRINT 'Static data value 25007 - Generated already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF