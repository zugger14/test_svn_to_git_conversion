IF COL_LENGTH('process_risk_controls', 'action_type_secondary') IS NULL
BEGIN
    ALTER TABLE process_risk_controls ADD action_type_secondary INT
END
GO

IF COL_LENGTH('process_risk_controls', 'action_label_secondary') IS NULL
BEGIN
    ALTER TABLE process_risk_controls ADD action_label_secondary VARCHAR(1000)
END
GO

IF COL_LENGTH('process_risk_controls', 'document_template') IS NULL
BEGIN
    ALTER TABLE process_risk_controls ADD document_template INT
END
GO

IF COL_LENGTH('process_risk_controls', 'trigger_primary') IS NULL
BEGIN
    ALTER TABLE process_risk_controls ADD trigger_primary INT
END
GO

IF COL_LENGTH('process_risk_controls', 'trigger_secondary') IS NULL
BEGIN
    ALTER TABLE process_risk_controls ADD trigger_secondary INT
END
GO

