IF COL_LENGTH('workflow_message_tag','is_hyperlink') IS NULL
BEGIN
	ALTER TABLE workflow_message_tag
	ADD is_hyperlink INT NULL DEFAULT 0
END
