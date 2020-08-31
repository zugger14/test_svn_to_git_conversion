IF COL_LENGTH('process_risk_controls_activities', 'source_column') IS NULL
BEGIN
    ALTER TABLE process_risk_controls_activities ADD source_column VARCHAR(300)
END
GO