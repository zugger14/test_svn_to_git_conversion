IF COL_LENGTH('source_deal_prepay','value') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_prepay ALTER COLUMN [value] NUMERIC(32,20)
END
GO