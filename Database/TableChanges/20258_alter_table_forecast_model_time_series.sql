IF COL_LENGTH('forecast_model', 'time_series') IS NULL
BEGIN
    ALTER TABLE forecast_model ADD time_series int
END
GO