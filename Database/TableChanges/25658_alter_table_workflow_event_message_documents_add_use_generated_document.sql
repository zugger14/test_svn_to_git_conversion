IF COL_LENGTH('workflow_event_message_documents','use_generated_document') IS NULL
BEGIN
	ALTER TABLE workflow_event_message_documents
	ADD  [use_generated_document] NCHAR(1) NULL
END
