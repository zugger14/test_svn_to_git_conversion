SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106702)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106702, 106700, 'Import', 'Import', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106702 - Import.'
END
ELSE
BEGIN
    PRINT 'Static data value 106702 - Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106701)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106701, 106700, 'Invoice', 'Invoice', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106701 - Invoice.'
END
ELSE
BEGIN
    PRINT 'Static data value 106701 - Invoice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 106700)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (106700, 106700, 'Report', 'Report', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 106700 - Report.'
END
ELSE
BEGIN
    PRINT 'Static data value 106700 - Report already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF