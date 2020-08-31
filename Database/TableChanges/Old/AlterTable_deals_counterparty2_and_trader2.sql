IF COL_LENGTH('source_deal_header', 'counterparty_id2') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD counterparty_id2 INT REFERENCES source_counterparty(source_counterparty_id);
END
GO

IF COL_LENGTH('source_deal_header_template', 'counterparty_id2') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD counterparty_id2 INT REFERENCES source_counterparty(source_counterparty_id);
END
GO

IF COL_LENGTH('delete_source_deal_header', 'counterparty_id2') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD counterparty_id2 INT 
END
GO

IF COL_LENGTH('source_deal_header_audit', 'counterparty_id2') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD counterparty_id2 INT REFERENCES source_counterparty(source_counterparty_id);
END
GO


IF COL_LENGTH('source_deal_header', 'trader_id2') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD trader_id2 INT REFERENCES source_traders(source_trader_id);
END
GO

IF COL_LENGTH('source_deal_header_template', 'trader_id2') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD trader_id2 INT REFERENCES source_traders(source_trader_id);
END
GO

IF COL_LENGTH('delete_source_deal_header', 'trader_id2') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD trader_id2 INT 
END
GO

IF COL_LENGTH('source_deal_header_audit', 'trader_id2') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD trader_id2 INT REFERENCES source_traders(source_trader_id);
END
GO

