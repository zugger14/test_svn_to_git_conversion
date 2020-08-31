IF COL_LENGTH('workflow_activities', 'XML_process_data') IS NULL
BEGIN
    ALTER TABLE workflow_activities ADD XML_process_data XML NULL
END
ELSE
BEGIN
    PRINT 'XML_process_data Already Exists.'
END 
GO
