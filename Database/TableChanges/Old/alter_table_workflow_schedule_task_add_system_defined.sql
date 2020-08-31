IF COL_LENGTH('workflow_schedule_task', 'system_defined') IS NULL
BEGIN
    ALTER TABLE workflow_schedule_task ADD system_defined INT
END
GO

