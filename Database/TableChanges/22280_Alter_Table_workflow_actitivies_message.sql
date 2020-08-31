IF COL_LENGTH(N'workflow_activities', N'message') IS NOT NULL
BEGIN
	ALTER TABLE workflow_activities ALTER COLUMN message VARCHAR(MAX)
END