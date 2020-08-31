IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 110300)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (110300, 'Fix Message Tag Definition', 'Fix Message Tag Definition', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 110300 - Fix Message Tag Definition.'
END
ELSE
BEGIN
    PRINT 'Static data type 110300 - Fix Message Tag Definition already EXISTS.'
END


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110300)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110300, 110300, 'Tag Id', 'Tag Id', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110300 - Tag Id.'
END
ELSE
BEGIN
    PRINT 'Static data value 110300 - Tag Id already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110301)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110300, 110301, 'Field Name', 'Field Name', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110301 - Field Name.'
END
ELSE
BEGIN
    PRINT 'Static data value 110301 - Field Name already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110302)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110300, 110302, 'Conditional Value', 'Conditional Value', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110302 - Conditional Value.'
END
ELSE
BEGIN
    PRINT 'Static data value 110302 - Conditional Value already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110303)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110300, 110303, 'Table Field Name', 'Table Field Name', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110303 - Table Field Name.'
END
ELSE
BEGIN
    PRINT 'Static data value 110303 - Table Field Name already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF 

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110304)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110300, 110304, 'Tag Type', 'Tag Type', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110304 - Tag Type.'
END
ELSE
BEGIN
    PRINT 'Static data value 110304 - Tag Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF                                   