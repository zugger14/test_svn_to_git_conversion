IF COL_LENGTH('source_deal_detail', 'detail_sample_control') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD detail_sample_control CHAR(1)
END
GO

IF COL_LENGTH('source_deal_detail_template', 'detail_sample_control') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD detail_sample_control CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'detail_sample_control') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD detail_sample_control CHAR(1)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'detail_sample_control') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD detail_sample_control CHAR(1)
END
GO

IF COL_LENGTH('source_deal_header', 'sample_control') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD sample_control CHAR(1)
END
GO

IF COL_LENGTH('source_deal_header_template', 'sample_control') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD sample_control CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_header', 'sample_control') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD sample_control CHAR(1)
END
GO

IF COL_LENGTH('source_deal_header_audit', 'sample_control') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD sample_control CHAR(1)
END
GO