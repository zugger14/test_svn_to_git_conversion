IF NOT EXISTS(SELECT * FROM workflow_module_event_mapping WHERE module_id = 20603 AND event_id = 20568)
BEGIN
	INSERT INTO workflow_module_event_mapping(module_id, event_id, is_active) VALUES
	(20603, 20568, 1)
END
