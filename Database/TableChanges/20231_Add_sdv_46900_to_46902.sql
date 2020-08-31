SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46902)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46902, 46900, 'Financial settlement', 'Financial settlement', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46902 - Financial settlement.'
END
ELSE
BEGIN
    PRINT 'Static data value 46902 - Financial settlement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46901)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46901, 46900, 'Physical settlement', 'Physical settlement', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46901 - Physical settlement.'
END
ELSE
BEGIN
    PRINT 'Static data value 46901 - Physical settlement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 46900)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (46900, 46900, 'Cash Settlement', 'Cash Settlement', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 46900 - Cash Settlement.'
END
ELSE
BEGIN
    PRINT 'Static data value 46900 - Cash Settlement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF