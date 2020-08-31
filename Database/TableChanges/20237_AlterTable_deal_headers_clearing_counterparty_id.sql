IF COL_LENGTH('source_deal_header', 'clearing_counterparty_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD clearing_counterparty_id INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'clearing_counterparty_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD clearing_counterparty_id INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'clearing_counterparty_id') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD clearing_counterparty_id INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'clearing_counterparty_id') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD clearing_counterparty_id INT
END
GO