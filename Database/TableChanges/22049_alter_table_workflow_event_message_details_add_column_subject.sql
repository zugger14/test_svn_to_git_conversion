IF COL_LENGTH('workflow_event_message_details','subject') IS NULL
BEGIN
	ALTER TABLE workflow_event_message_details
	ADD  [subject] VARCHAR(1000)
END