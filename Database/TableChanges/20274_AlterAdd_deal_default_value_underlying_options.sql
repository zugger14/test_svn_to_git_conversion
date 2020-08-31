IF COL_LENGTH('deal_default_value', 'underlying_options') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD underlying_options INT
END
GO