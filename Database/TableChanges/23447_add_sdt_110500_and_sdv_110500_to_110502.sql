IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 110500)
BEGIN
    INSERT INTO static_data_type([type_id], [type_name], [description], [internal], [is_active], create_user, create_ts)
    VALUES (110500, 'WACOG Option', 'WACOG Option', 1, 1, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data type 110500 - WACOG Option.'
END
ELSE
BEGIN
    PRINT 'Static data type 110500 - WACOG Option already EXISTS.'
END 

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110500)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110500, 110500, 'Prior Day', 'Prior Day', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110500 - Prior Day.'
END
ELSE
BEGIN
    PRINT 'Static data value 110500 - Prior Day already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110501)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110500, 110501, 'Prior Month', 'Prior Month', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110501 - Prior Month.'
END
ELSE
BEGIN
    PRINT 'Static data value 110501 - Prior Month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 110502)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (110500, 110502, 'Current Month', 'Current Month', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 110502 - Current Month.'
END
ELSE
BEGIN
    PRINT 'Static data value 110502 - Current Month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF         
GO   