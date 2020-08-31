IF COL_LENGTH('source_deal_prepay_audit','value') IS NOT NULL
BEGIN
    ALTER TABLE source_deal_prepay_audit ALTER COLUMN [value] NUMERIC(32,20)
END
GO
