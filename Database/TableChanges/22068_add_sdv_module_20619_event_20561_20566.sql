--Module
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20619)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20600, 20619, 'EOD', 'EOD', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20619 - EOD.'
END
ELSE
BEGIN
    PRINT 'Static data value 20619 - EOD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF  

-- event 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20561)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 20561, 'EOD Process', 'EOD Process', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20561 - EOD Process.'
END
ELSE
BEGIN
    PRINT 'Static data value 20561 - EOD Process already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF  


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20566)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 20566, 'EOD Error', 'EOD Error', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20566 - EOD Error.'
END
ELSE
BEGIN
    PRINT 'Static data value 20566 - EOD Error already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF 

                  