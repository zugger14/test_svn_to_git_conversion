IF COL_LENGTH('var_measurement_criteria_detail', 'update_ts') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria_detail ADD [update_ts] DATETIME NULL
END
GO


IF COL_LENGTH('var_measurement_criteria_detail', 'update_user') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria_detail ADD [update_user] VARCHAR(50) NULL
END
GO

IF COL_LENGTH('var_measurement_criteria_detail', 'create_ts') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria_detail ADD [create_ts] DATETIME NULL DEFAULT GETDATE()
END
GO

IF COL_LENGTH('var_measurement_criteria_detail', 'create_user') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria_detail ADD [create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
END
GO
