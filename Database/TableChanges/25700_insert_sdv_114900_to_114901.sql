SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 114900)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (114900, 114900, 'Deal Transfer Adjust', 'Deal Transfer Adjust Workflow', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 114900 - Deal Transfer Adjust.'
END
ELSE
BEGIN
    PRINT 'Static data value 114900 - Deal Transfer Adjust already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF       


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 114901)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (114900, 114901, 'Power Auto Balancing', 'Power Auto Balancing workflow', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 114901 - Power Auto Balancing.'
END
ELSE
BEGIN
    PRINT 'Static data value 114901 - Power Auto Balancing already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            