IF COL_LENGTH('source_deal_header_template', 'is_gas_daily') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD is_gas_daily CHAR(1)
END
GO