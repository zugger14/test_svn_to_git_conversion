IF COL_LENGTH('forecast_model', 'active') IS NULL
BEGIN
    ALTER TABLE forecast_model ADD active char
END
GO