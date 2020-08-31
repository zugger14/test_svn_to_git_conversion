IF COL_LENGTH('source_deal_detail', 'crop_year') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD crop_year INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'crop_year') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD crop_year INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'crop_year') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD crop_year INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'crop_year') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD crop_year INT
END
GO