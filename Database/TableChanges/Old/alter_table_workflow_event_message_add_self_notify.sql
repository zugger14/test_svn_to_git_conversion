IF COL_LENGTH('workflow_event_message','self_notify') IS NULL
BEGIN
	ALTER TABLE workflow_event_message add self_notify CHAR(1) NOT NULL DEFAULT 'n'
END
ELSE 
	PRINT 'Column Already Exists.'