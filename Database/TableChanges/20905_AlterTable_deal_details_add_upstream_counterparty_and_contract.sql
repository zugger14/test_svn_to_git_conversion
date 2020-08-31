IF COL_LENGTH('source_deal_detail', 'upstream_counterparty') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD upstream_counterparty INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'upstream_counterparty') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD upstream_counterparty INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'upstream_counterparty') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD upstream_counterparty INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'upstream_counterparty') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD upstream_counterparty INT
END
GO

IF COL_LENGTH('source_deal_detail', 'upstream_contract') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD upstream_contract INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'upstream_contract') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD upstream_contract INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'upstream_contract') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD upstream_contract INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'upstream_contract') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD upstream_contract INT
END
GO