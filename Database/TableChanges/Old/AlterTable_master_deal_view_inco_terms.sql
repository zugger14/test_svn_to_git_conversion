IF COL_LENGTH('master_deal_view', 'inco_terms') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD inco_terms VARCHAR(500)
END
GO

IF COL_LENGTH('master_deal_view', 'detail_inco_terms') IS NULL
BEGIN
    ALTER TABLE master_deal_view ADD detail_inco_terms VARCHAR(500)
END
GO
