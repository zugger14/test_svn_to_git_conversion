IF COL_LENGTH('mv90_data', 'granularity') IS NULL
BEGIN
    ALTER TABLE mv90_data ADD granularity INT
END
GO