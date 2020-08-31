IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 112300)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (112300, 'Process Queue Type', 'Process Queue Type', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 112300 - Process Queue Type.'
END
ELSE
BEGIN
    PRINT 'Static data type 112300 - Process Queue Type already EXISTS.'
END            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112300)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112300, 112300, 'Import', 'Import', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112300 - Import.'
END
ELSE
BEGIN
    PRINT 'Static data value 112300 - Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF                   