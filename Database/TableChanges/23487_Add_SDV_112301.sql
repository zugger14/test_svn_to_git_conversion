SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 112301)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (112300, 112301, 'Workflow', 'Workflow', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 112301 - Workflow.'
END
ELSE
BEGIN
    PRINT 'Static data value 112301 - Workflow already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            