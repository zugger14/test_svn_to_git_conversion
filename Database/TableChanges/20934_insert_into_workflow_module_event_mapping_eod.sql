IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20619 AND event_id = 20561)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20619,	20561,	1
END