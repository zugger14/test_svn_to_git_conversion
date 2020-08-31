IF COL_LENGTH('source_deal_detail', 'detail_commodity_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD detail_commodity_id INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'detail_commodity_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD detail_commodity_id INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'detail_commodity_id') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD detail_commodity_id INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'detail_commodity_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD detail_commodity_id INT
END
GO

IF COL_LENGTH('source_deal_header', 'counterparty_trader') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD counterparty_trader INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'counterparty_trader') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD counterparty_trader INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'counterparty_trader') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD counterparty_trader INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'counterparty_trader') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD counterparty_trader INT
END
GO

IF COL_LENGTH('source_deal_header', 'internal_counterparty') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD internal_counterparty INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'internal_counterparty') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD internal_counterparty INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'internal_counterparty') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD internal_counterparty INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'internal_counterparty') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD internal_counterparty INT
END
GO

IF COL_LENGTH('source_deal_header', 'settlement_vol_type') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD settlement_vol_type CHAR(1)
END
GO

IF COL_LENGTH('source_deal_header_template', 'settlement_vol_type') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD settlement_vol_type CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_header', 'settlement_vol_type') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD settlement_vol_type CHAR(1)
END
GO

IF COL_LENGTH('source_deal_header_audit', 'settlement_vol_type') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD settlement_vol_type CHAR(1)
END
GO

IF COL_LENGTH('source_deal_detail', 'detail_pricing') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD detail_pricing INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'detail_pricing') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD detail_pricing INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'detail_pricing') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD detail_pricing INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'detail_pricing') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD detail_pricing INT
END
GO

IF COL_LENGTH('source_deal_detail', 'pricing_start') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD pricing_start DATETIME
END
GO

IF COL_LENGTH('source_deal_detail_template', 'pricing_start') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD pricing_start DATETIME
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'pricing_start') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD pricing_start DATETIME
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'pricing_start') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD pricing_start DATETIME
END
GO


IF COL_LENGTH('source_deal_detail', 'pricing_end') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD pricing_end DATETIME
END
GO

IF COL_LENGTH('source_deal_detail_template', 'pricing_end') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD pricing_end DATETIME
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'pricing_end') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD pricing_end DATETIME
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'pricing_end') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD pricing_end DATETIME
END
GO 




