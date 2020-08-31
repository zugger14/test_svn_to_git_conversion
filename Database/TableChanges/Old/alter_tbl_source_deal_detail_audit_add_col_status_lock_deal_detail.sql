IF COL_LENGTH('source_deal_detail_audit', 'status') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD [status] INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'lock_deal_detail') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD lock_deal_detail CHAR(1)
END
GO