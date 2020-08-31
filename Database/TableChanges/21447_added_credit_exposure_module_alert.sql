SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20623)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20623, 20600, 'Credit Exposure', 'Credit Exposure', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20623 - Credit Exposure.'
END
ELSE
BEGIN
    PRINT 'Static data value 20623 - Credit Exposure already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping  w
				INNER JOIN alert_table_definition atd ON atd.alert_table_definition_id = w.rule_table_id
				WHERE w.module_id = 20623 AND atd.logical_table_name = 'Credit Exposure Detail')
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT  20623, atd.alert_table_definition_id, 1 FROM alert_table_definition atd 
	WHERE atd.logical_table_name = 'Credit Exposure Detail'
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20623 AND event_id = 20508)
BEGIN
 INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
 SELECT 20623,20508,1 
END

