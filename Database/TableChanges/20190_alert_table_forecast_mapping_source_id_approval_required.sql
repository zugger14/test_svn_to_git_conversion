IF COL_LENGTH('forecast_mapping', 'source_id') IS NULL
BEGIN
    ALTER TABLE forecast_mapping ADD source_id int
END
GO

IF COL_LENGTH('forecast_mapping', 'approval_required') IS NULL
BEGIN
    ALTER TABLE forecast_mapping ADD approval_required char
END
GO