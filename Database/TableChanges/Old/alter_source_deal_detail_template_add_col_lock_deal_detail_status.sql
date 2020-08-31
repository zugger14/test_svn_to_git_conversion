IF COL_LENGTH('source_deal_detail_template', 'status') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD [status] INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'lock_deal_detail') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD lock_deal_detail CHAR(1)
END
GO


