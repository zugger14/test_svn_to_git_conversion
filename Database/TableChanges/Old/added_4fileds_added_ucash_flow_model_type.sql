IF COL_LENGTH('cash_flow_model_type', 'create_user') IS NULL
BEGIN
    ALTER TABLE cash_flow_model_type ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('cash_flow_model_type', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE cash_flow_model_type ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('cash_flow_model_type', '[update_user]') IS NULL
BEGIN
    ALTER TABLE cash_flow_model_type ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('cash_flow_model_type', 'update_ts') IS NULL
BEGIN
    ALTER TABLE cash_flow_model_type ADD [update_ts] DATETIME NULL
END