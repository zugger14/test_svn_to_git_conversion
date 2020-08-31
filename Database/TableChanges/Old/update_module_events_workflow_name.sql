UPDATE m
SET m.workflow_name = me.event_id
FROM module_events me
LEFT JOIN module_events m ON m.module_events_id = me.module_events_id
WHERE m.workflow_name IS NULL