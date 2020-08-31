IF COL_LENGTH('application_notes', 'workflow_process_id') IS NULL
BEGIN
    ALTER TABLE application_notes ADD workflow_process_id VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'workflow_process_id Already Exists.'
END 
GO

IF COL_LENGTH('application_notes', 'workflow_message_id') IS NULL
BEGIN
    ALTER TABLE application_notes ADD workflow_message_id INT NULL
END
ELSE
BEGIN
    PRINT 'workflow_message_id Already Exists.'
END 
GO