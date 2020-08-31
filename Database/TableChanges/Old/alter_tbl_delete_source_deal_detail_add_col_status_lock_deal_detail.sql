IF COL_LENGTH('delete_source_deal_detail', 'status') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD [status] INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'lock_deal_detail') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD lock_deal_detail CHAR(1)
END
GO