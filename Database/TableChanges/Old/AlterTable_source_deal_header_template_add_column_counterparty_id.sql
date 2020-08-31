IF COL_LENGTH('source_deal_header_template', 'counterparty_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD counterparty_id INT REFERENCES source_counterparty(source_counterparty_id)
END
GO