UPDATE forecast_result
SET maturity = CONVERT(VARCHAR(50), maturity, 120)
GO

IF COL_LENGTH('forecast_result', 'maturity') IS NOT NULL
BEGIN
    ALTER TABLE forecast_result ALTER COLUMN maturity DATETIME
END
GO