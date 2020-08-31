IF COL_LENGTH('workflow_event_message','notification_type') IS NOT NULL
	ALTER TABLE workflow_event_message ALTER COLUMN notification_type VARCHAR(1000)

IF COL_LENGTH('alert_sql','notification_type') IS NOT NULL
	ALTER TABLE alert_sql ALTER COLUMN notification_type VARCHAR(1000)