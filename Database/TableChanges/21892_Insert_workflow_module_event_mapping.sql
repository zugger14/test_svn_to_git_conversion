IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id= 20601 AND event_id = 20515)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601, 20515, 1
END