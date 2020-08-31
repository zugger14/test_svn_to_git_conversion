IF COL_LENGTH('workflow_message_tag','workflow_message') IS NULl
BEGIN
	ALTER TABLE workflow_message_tag
	ADD workflow_message VARCHAR(MAX)
END

