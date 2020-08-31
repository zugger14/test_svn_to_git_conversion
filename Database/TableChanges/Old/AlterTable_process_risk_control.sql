IF COL_LENGTH('process_risk_controls', 'action_type_on_approve') IS NULL
BEGIN
    ALTER TABLE process_risk_controls ADD action_type_on_approve INT NULL
END
GO

IF COL_LENGTH('process_risk_controls', 'action_label_on_approve') IS NULL
BEGIN
    ALTER TABLE process_risk_controls ADD action_label_on_approve VARCHAR(100) NULL
END
GO

IF COL_LENGTH('process_risk_controls', 'action_type_on_complete') IS NULL
BEGIN
    ALTER TABLE process_risk_controls ADD action_type_on_complete INT NULL
END
GO

IF COL_LENGTH('process_risk_controls', 'action_label_on_complete') IS NULL
BEGIN
    ALTER TABLE process_risk_controls ADD action_label_on_complete VARCHAR(100) NULL
END
GO


IF COL_LENGTH('process_risk_controls_activities', 'process_id') IS NULL
BEGIN
    ALTER TABLE process_risk_controls_activities ADD process_id VARCHAR(200) NULL
END
GO