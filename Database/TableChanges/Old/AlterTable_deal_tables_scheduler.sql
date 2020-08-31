IF COL_LENGTH('source_deal_header', 'scheduler') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD scheduler INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'scheduler') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD scheduler INT
END
GO

IF COL_LENGTH('delete_source_deal_header', 'scheduler') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD scheduler INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'scheduler') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD scheduler INT
END
GO

IF COL_LENGTH('master_deal_view', 'scheduler') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD scheduler VARCHAR(300)
END
GO