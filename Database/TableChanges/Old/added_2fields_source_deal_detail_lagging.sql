IF COL_LENGTH('source_deal_detail_lagging', '[update_user]') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_lagging ADD [update_user] VARCHAR(50) NULL
END

IF COL_LENGTH('source_deal_detail_lagging', 'update_ts') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_lagging ADD [update_ts] DATETIME NULL
END