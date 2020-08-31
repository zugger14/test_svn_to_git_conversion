IF COL_LENGTH('workflow_activities', 'workflow_process_id') IS NULL
BEGIN
    ALTER TABLE workflow_activities ADD workflow_process_id VARCHAR(300) NULL
END
ELSE
BEGIN
    PRINT 'workflow_process_id Already Exists.'
END 
GO