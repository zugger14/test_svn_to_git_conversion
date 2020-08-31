IF COL_LENGTH('forecast_mapping', 'model') IS NULL
BEGIN
    ALTER TABLE forecast_mapping ADD model VARBINARY(MAX)
END
GO