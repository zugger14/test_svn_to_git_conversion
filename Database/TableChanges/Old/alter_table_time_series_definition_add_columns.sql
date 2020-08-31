IF COL_LENGTH('time_series_definition', 'effective_date_applicable') IS NULL
BEGIN
    ALTER TABLE time_series_definition ADD effective_date_applicable CHAR(1) 
END
GO

IF COL_LENGTH('time_series_definition', 'maturity_applicable') IS NULL
BEGIN
    ALTER TABLE time_series_definition ADD maturity_applicable CHAR(1) 
END
GO

