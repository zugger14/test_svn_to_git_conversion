IF COL_LENGTH('workflow_activities', 'workflow_group_id') IS NULL
BEGIN
    ALTER TABLE workflow_activities ADD workflow_group_id INT
END
GO