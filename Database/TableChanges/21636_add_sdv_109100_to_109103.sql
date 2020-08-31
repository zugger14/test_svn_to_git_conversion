SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109100)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109100, 109100, 'SaaS', 'SaaS', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109100 - SaaS.'
END
ELSE
BEGIN
    PRINT 'Static data value 109100 - SaaS already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109101)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109100, 109101, 'Prospect', 'Prospect', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109101 - Prospect.'
END
ELSE
BEGIN
    PRINT 'Static data value 109101 - Prospect already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109102)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109100, 109102, 'Demo', 'Demo', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109102 - Demo.'
END
ELSE
BEGIN
    PRINT 'Static data value 109102 - Demo already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109103)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109100, 109103, 'Other', 'Other', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109103 - Other.'
END
ELSE
BEGIN
    PRINT 'Static data value 109103 - Other already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF