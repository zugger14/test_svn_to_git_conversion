IF COL_LENGTH('workflow_event_message_details', 'internal_contact_type') IS NULL
BEGIN
    ALTER TABLE workflow_event_message_details ADD internal_contact_type INT
END
GO

