IF COL_LENGTH('workflow_event_action', 'threshold_days') IS NULL
BEGIN
    ALTER TABLE workflow_event_action ADD threshold_days INT
END
GO

