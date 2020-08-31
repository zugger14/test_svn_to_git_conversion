IF COL_LENGTH('assignment_audit', 'assigned_volume') IS NOT NULL
BEGIN
    ALTER TABLE assignment_audit ALTER COLUMN assigned_volume NUMERIC(38, 20) NULL
END
GO