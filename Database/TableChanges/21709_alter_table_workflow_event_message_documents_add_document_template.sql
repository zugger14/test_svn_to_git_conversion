IF COL_LENGTH('workflow_event_message_documents', 'document_template') IS NULL
BEGIN
    ALTER TABLE workflow_event_message_documents ADD document_template INT
END
ELSE
BEGIN
    PRINT 'document_template Already Exists.'
END 
GO