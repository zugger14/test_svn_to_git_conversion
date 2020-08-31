SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19315)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (19300, 19315, 'Balance of the Week', 'Balance of the Week', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 19315 - Balance of the Week.'
END
ELSE
BEGIN
    PRINT 'Static data value 19315 - Balance of the Week already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19316)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (19300, 19316, 'Balance of the Month', 'Balance of the Month', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 19316 - Balance of the Month.'
END
ELSE
BEGIN
    PRINT 'Static data value 19316 - Balance of the Month already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19317)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (19300, 19317, 'Balance of the Quarter', 'Balance of the Quarter', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 19317 - Balance of the Quarter.'
END
ELSE
BEGIN
    PRINT 'Static data value 19317 - Balance of the Quarter already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19318)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (19300, 19318, 'Balance of the Year', 'Balance of the Year', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 19318 - Balance of the Year.'
END
ELSE
BEGIN
    PRINT 'Static data value 19318 - Balance of the Year already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            