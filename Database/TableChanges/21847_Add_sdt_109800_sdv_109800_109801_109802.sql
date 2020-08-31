IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 109800)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (109800, 'Netting Type', 'Netting Type', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 109800 - Netting Type.'
END
ELSE
BEGIN
    PRINT 'Static data type 109800 - Netting Type already EXISTS.'
END            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109800)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109800, 109800, 'Credit', 'Credit', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109800 - Credit.'
END
ELSE
BEGIN
    PRINT 'Static data value 109800 - Credit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109801)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109800, 109801, 'Settlement', 'Settlement', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109801 - Settlement.'
END
ELSE
BEGIN
    PRINT 'Static data value 109801 - Settlement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF               

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 109802)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (109800, 109802, 'Both', 'Both', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 109802 - Both.'
END
ELSE
BEGIN
    PRINT 'Static data value 109802 - Both already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            