IF COL_LENGTH('message_board', 'workflow_activity_id') IS NULL
BEGIN
	ALTER TABLE message_board ADD workflow_activity_id INT
END
GO 
