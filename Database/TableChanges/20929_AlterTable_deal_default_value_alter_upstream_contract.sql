IF COL_LENGTH('deal_default_value', 'upstream_contract') IS NOT NULL
BEGIN
    ALTER TABLE deal_default_value ALTER COLUMN upstream_contract VARCHAR(500)
END
GO