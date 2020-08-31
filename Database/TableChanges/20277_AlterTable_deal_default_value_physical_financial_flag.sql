IF COL_LENGTH('deal_default_value', 'physical_financial_flag') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD physical_financial_flag CHAR(1)
END
GO