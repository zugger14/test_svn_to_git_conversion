IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 110000)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (110000, 'Fix Configuration Mapping', 'Fix Configuration Mapping', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 110000 - Fix Configuration Mapping.'
END
ELSE
BEGIN
    PRINT 'Static data type 110000 - Fix Configuration Mapping already EXISTS.'
END 

UPDATE static_data_type
SET [type_name] = 'Fix Configuration Mapping',
    [description] = 'Fix Configuration Mapping',
    [internal] = 1, 
    [is_active] = 1
WHERE [type_id] = 110000
PRINT 'Updated static data type 110000 - Fix Configuration Mapping.'            

-- Exchange
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110000)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110000, 110000, 'Exchange', 'Fix Exchange Name', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110000 - Exchange.'
END
ELSE
BEGIN
    PRINT 'Static data value 110000 - Exchange already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF  

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110000)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110000, 110000, 'Exchange', 'Fix Exchange Name', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110000 - Exchange.'
END
ELSE
BEGIN
    PRINT 'Static data value 110000 - Exchange already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

-- Exchange Session settings variable
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110001)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110000, 110001, 'Variable', 'Exchange Variable', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110001 - Variable.'
END
ELSE
BEGIN
    PRINT 'Static data value 110001 - Variable already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       

UPDATE static_data_value
    SET [code] = 'Variable',
        [category_id] = NULL
    WHERE [value_id] = 110001
PRINT 'Updated Static value 110001 - Variable.' 

--Exchange Variable Value
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110002)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110000, 110002, 'Configuration Value', 'Exchange Variable Value', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110002 - Configuration Value.'
END
ELSE
BEGIN
    PRINT 'Static data value 110002 - Configuration Value already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF     

UPDATE static_data_value
    SET [code] = 'Configuration Value',
        [category_id] = NULL
    WHERE [value_id] = 110002
PRINT 'Updated Static value 110002 - Configuration Value.'            

-- Configuration Type
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110003)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110000, 110003, 'Configuration Type', 'Configuration Type', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110003 - Configuration Type.'
END
ELSE
BEGIN
    PRINT 'Static data value 110003 - Configuration Type already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF     

UPDATE static_data_value
    SET [code] = 'Configuration Type',
        [category_id] = NULL
    WHERE [value_id] = 110003
PRINT 'Updated Static value 110003 - Configuration Type.'                                                    