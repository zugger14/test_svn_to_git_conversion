IF COL_LENGTH('deal_fields_mapping', 'trader_id') IS NULL
BEGIN
    ALTER TABLE deal_fields_mapping ADD trader_id INT REFERENCES source_traders(source_trader_id)
END
GO