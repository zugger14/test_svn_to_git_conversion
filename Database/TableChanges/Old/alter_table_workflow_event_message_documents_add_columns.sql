IF COL_LENGTH('workflow_event_message_documents', 'document_category') IS NULL
BEGIN
    ALTER TABLE workflow_event_message_documents ADD document_category INT NULL
END
ELSE
BEGIN
    PRINT 'document_category Already Exists.'
END 
GO