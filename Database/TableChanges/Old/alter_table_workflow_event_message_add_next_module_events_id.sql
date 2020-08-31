IF COL_LENGTH('workflow_event_message', 'next_module_events_id') IS NULL
BEGIN
    ALTER TABLE workflow_event_message ADD next_module_events_id INT
END
GO

