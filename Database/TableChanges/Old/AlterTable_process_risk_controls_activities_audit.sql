IF COL_LENGTH('process_risk_controls_activities_audit', 'source_column') IS NULL
BEGIN
    ALTER TABLE process_risk_controls_activities_audit ADD source_column VARCHAR(300)
END
GO

IF COL_LENGTH('process_risk_controls_activities_audit', 'source') IS NULL
BEGIN
    ALTER TABLE process_risk_controls_activities_audit ADD source VARCHAR(300)
END
GO

IF COL_LENGTH('process_risk_controls_activities_audit', 'source_id') IS NULL
BEGIN
    ALTER TABLE process_risk_controls_activities_audit ADD source_id INT
END
GO