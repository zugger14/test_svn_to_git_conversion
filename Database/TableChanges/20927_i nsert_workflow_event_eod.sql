SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20566)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20566, 20500, 'EOD Error', 'EOD Error', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20566 - EOD Error.'
END
ELSE
BEGIN
    PRINT 'Static data value 20566 - EOD Error already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO


IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20619 AND event_id = 20566)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20619,	20566,	1
END
GO