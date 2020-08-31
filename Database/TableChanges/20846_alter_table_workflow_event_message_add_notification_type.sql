IF COL_LENGTH('workflow_event_message','notification_type') IS NULL
	ALTER TABLE workflow_event_message ADD notification_type INT