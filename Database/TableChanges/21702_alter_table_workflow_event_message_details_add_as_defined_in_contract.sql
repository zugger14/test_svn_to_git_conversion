IF COL_LENGTH('workflow_event_message_details', 'as_defined_in_contact') IS NULL
BEGIN
    ALTER TABLE workflow_event_message_details ADD as_defined_in_contact CHAR(1)
END
ELSE
BEGIN
    PRINT 'as_defined_in_contact Already Exists.'
END 
GO