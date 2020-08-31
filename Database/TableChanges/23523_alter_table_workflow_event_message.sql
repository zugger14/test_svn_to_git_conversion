--ALTER TABLE workflow_event_message ALTER COLUMN self_notify NCHAR (1);--conflict
--ALTER TABLE workflow_event_message ALTER COLUMN notify_trader NCHAR (1);
--ALTER TABLE workflow_event_message ALTER COLUMN create_user NVARCHAR (50); --conflict
--ALTER TABLE workflow_event_message ALTER COLUMN mult_approval_required NCHAR (1); --conflict

IF COL_LENGTH('workflow_event_message', 'event_message_name') IS NOT NULL
	ALTER TABLE workflow_event_message ALTER COLUMN event_message_name NVARCHAR (100);

IF COL_LENGTH('workflow_event_message', '[message]') IS NOT NULL
	ALTER TABLE workflow_event_message ALTER COLUMN [message] NVARCHAR (1000);

IF COL_LENGTH('workflow_event_message', 'comment_required') IS NOT NULL
	ALTER TABLE workflow_event_message ALTER COLUMN comment_required NCHAR (1);

IF COL_LENGTH('workflow_event_message', 'approval_action_required') IS NOT NULL
	ALTER TABLE workflow_event_message ALTER COLUMN approval_action_required NCHAR (1);

IF COL_LENGTH('workflow_event_message', 'update_user') IS NOT NULL
	ALTER TABLE workflow_event_message ALTER COLUMN update_user NVARCHAR (50);

IF COL_LENGTH('workflow_event_message', 'optional_event_msg') IS NOT NULL
	ALTER TABLE workflow_event_message ALTER COLUMN optional_event_msg NCHAR (1);

IF COL_LENGTH('workflow_event_message', 'automatic_proceed') IS NOT NULL
	ALTER TABLE workflow_event_message ALTER COLUMN automatic_proceed NCHAR (1);

IF COL_LENGTH('workflow_event_message', 'notification_type') IS NOT NULL
	ALTER TABLE workflow_event_message ALTER COLUMN notification_type NVARCHAR (1000);