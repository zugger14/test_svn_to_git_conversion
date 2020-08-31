IF COL_LENGTH('source_deal_detail', 'source_deal_group_id') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD source_deal_group_id INT
END
GO