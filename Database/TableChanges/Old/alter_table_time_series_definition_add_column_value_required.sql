IF COL_LENGTH('time_series_definition', 'value_required') IS NULL
BEGIN
    ALTER TABLE time_series_definition ADD value_required VARCHAR(1) NOT NULL DEFAULT 'n'
END
GO
