IF COL_LENGTH('workflow_message_tag','application_function_id') IS NULL
BEGIN
	ALTER TABLE workflow_message_tag
	ADD application_function_id VARCHAR(1000)
END