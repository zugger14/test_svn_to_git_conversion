IF COL_LENGTH('forecast_model', 'sequential_forecast') IS NULL
BEGIN
    ALTER TABLE forecast_model ADD sequential_forecast char
END
GO

