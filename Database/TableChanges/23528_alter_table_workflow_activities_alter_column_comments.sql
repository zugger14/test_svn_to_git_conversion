IF COL_LENGTH('workflow_activities', 'comments') IS NOT NULL
	ALTER TABLE workflow_activities ALTER COLUMN comments NVARCHAR (4000);