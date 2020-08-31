IF COL_LENGTH('workflow_event_message', 'minimum_approval_required') IS NULL
BEGIN
    ALTER TABLE workflow_event_message ADD minimum_approval_required INT
END
GO


IF COL_LENGTH('workflow_event_message', 'optional_event_msg') IS NULL
BEGIN
    ALTER TABLE workflow_event_message ADD optional_event_msg CHAR(1)
END
GO