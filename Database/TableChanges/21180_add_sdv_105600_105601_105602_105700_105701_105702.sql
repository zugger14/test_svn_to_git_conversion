SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105600)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105600, 105600, 'Simple', 'Simple', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105600 - Simple.'
END
ELSE
BEGIN
    PRINT 'Static data value 105600 - Simple already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105601)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105601, 105600, 'Compound', 'Compound', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105601 - Compound.'
END
ELSE
BEGIN
    PRINT 'Static data value 105601 - Compound already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105602)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105602, 105600, 'Continious Compund ', 'Continious Compund ', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105602 - Continious Compund .'
END
ELSE
BEGIN
    PRINT 'Static data value 105602 - Continious Compund  already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105700)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105700, 105700, 'Absolute Value', 'Absolute Value', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105700 - Absolute Value.'
END
ELSE
BEGIN
    PRINT 'Static data value 105700 - Absolute Value already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105701)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105701, 105700, 'Apply -ve interest', 'Apply -ve interest', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105701 - Apply -ve interest.'
END
ELSE
BEGIN
    PRINT 'Static data value 105701 - Apply -ve interest already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 105702)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (105702, 105700, 'No Interest ', 'No Interest ', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 105702 - No Interest .'
END
ELSE
BEGIN
    PRINT 'Static data value 105702 - No Interest  already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF