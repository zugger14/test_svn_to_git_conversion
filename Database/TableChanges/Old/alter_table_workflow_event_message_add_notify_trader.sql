IF COL_LENGTH('workflow_event_message','notify_trader') IS NULL
BEGIN
	ALTER TABLE workflow_event_message add notify_trader CHAR(1) NOT NULL DEFAULT 'n'
END
ELSE 
	PRINT 'Column Already Exists.'