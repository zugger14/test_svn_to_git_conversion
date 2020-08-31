IF COL_LENGTH('deal_default_value', 'deal_sub_type_type_id') IS NULL
BEGIN
    ALTER TABLE deal_default_value ADD deal_sub_type_type_id INT REFERENCES source_deal_type(source_deal_type_id)
END
GO