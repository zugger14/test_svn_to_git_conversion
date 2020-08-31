IF COL_LENGTH('source_deal_detail', 'detail_inco_terms') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD detail_inco_terms INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'detail_inco_terms') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD detail_inco_terms INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'detail_inco_terms') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD detail_inco_terms INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'detail_inco_terms') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD detail_inco_terms INT
END
GO

IF COL_LENGTH('source_deal_header', 'inco_terms') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD inco_terms INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'inco_terms') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD inco_terms INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'inco_terms') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD inco_terms INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'inco_terms') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD inco_terms INT
END
GO