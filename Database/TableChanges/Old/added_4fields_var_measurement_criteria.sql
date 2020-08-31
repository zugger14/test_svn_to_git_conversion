IF COL_LENGTH('var_measurement_criteria', 'create_user') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria ADD [create_user] VARCHAR(50) DEFAULT dbo.FNADBUser()
END

IF COL_LENGTH('var_measurement_criteria', '[create_ts]') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria ADD [create_ts] DATETIME DEFAULT GETDATE()
END

IF COL_LENGTH('var_measurement_criteria', '[update_user]') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('var_measurement_criteria', 'update_ts') IS NULL
BEGIN
    ALTER TABLE var_measurement_criteria ADD [update_ts] DATETIME NULL
END