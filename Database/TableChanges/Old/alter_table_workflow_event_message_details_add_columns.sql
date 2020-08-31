IF COL_LENGTH('workflow_event_message_details', 'email') IS NULL
BEGIN
    ALTER TABLE workflow_event_message_details ADD email VARCHAR(300)
END
ELSE
BEGIN
    PRINT 'email Already Exists.'
END 
GO

IF COL_LENGTH('workflow_event_message_details', 'email_cc') IS NULL
BEGIN
    ALTER TABLE workflow_event_message_details ADD email_cc VARCHAR(300)
END
ELSE
BEGIN
    PRINT 'email_cc Already Exists.'
END 
GO

IF COL_LENGTH('workflow_event_message_details', 'email_bcc') IS NULL
BEGIN
    ALTER TABLE workflow_event_message_details ADD email_bcc VARCHAR(300)
END
ELSE
BEGIN
    PRINT 'email_bcc Already Exists.'
END 
GO

IF COL_LENGTH('workflow_event_message_details', 'counterparty_contact_type') IS NOT NULL
BEGIN
    ALTER TABLE workflow_event_message_details ALTER COLUMN counterparty_contact_type INT
END 
GO

IF COL_LENGTH('workflow_event_message_details', 'delivery_method') IS NOT NULL
BEGIN
    ALTER TABLE workflow_event_message_details ALTER COLUMN delivery_method INT
END 
GO