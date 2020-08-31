SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112213)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112213, 'Having Prefix (Folder)', 'Having Prefix (Folder)', 21400, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112213 - Having Prefix (Folder).'
END
ELSE
BEGIN
    PRINT 'Static data value 112213 - Having Prefix (Folder) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112214)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112200, 112214, 'Having File Extension (Folder)', 'Having File Extension (Folder)', 21400, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112214 - Having File Extension (Folder).'
END
ELSE
BEGIN
    PRINT 'Static data value 112214 - Having File Extension (Folder) already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            