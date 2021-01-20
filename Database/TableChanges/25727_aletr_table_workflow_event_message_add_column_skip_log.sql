IF COL_LENGTH('workflow_event_message', 'skip_log') IS NULL
BEGIN
    ALTER TABLE workflow_event_message ADD skip_log NVARCHAR(1)
END
ELSE
BEGIN
    PRINT 'skip_log Already Exists.'
END 
GO