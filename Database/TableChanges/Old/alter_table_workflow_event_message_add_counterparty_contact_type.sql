IF COL_LENGTH('workflow_event_message', 'counterparty_contact_type') IS NULL
BEGIN
    ALTER TABLE workflow_event_message ADD counterparty_contact_type INT NULL
END
ELSE
BEGIN
    PRINT 'counterparty_contact_type Already Exists.'
END 
GO