
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20609 AND event_id = 20524)
BEGIN
 INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
 SELECT 20609,20524,1 
END


IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20604 AND event_id = 20507)
BEGIN
 INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
 SELECT 20604,20507,1 
END




 