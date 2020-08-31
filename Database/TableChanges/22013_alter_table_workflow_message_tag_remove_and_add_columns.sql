IF COL_LENGTH('workflow_message_tag','workflow_message') IS NOT NULL
BEGIN
	ALTER TABLE workflow_message_tag
	DROP column workflow_message
END

IF COL_LENGTH('workflow_message_tag','workflow_tag_query') IS NULL
BEGIN
	ALTER TABLE workflow_message_tag
	ADD workflow_tag_query VARCHAR(MAX)
END

IF COL_LENGTH('workflow_message_tag','system_defined') IS NULL
BEGIN
	ALTER TABLE workflow_message_tag
	ADD system_defined CHAR(1) DEFAULT 0
END
