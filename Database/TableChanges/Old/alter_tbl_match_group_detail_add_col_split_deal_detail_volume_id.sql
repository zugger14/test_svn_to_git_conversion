
IF COL_LENGTH('match_group_detail', 'split_deal_detail_volume_id') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD split_deal_detail_volume_id INT
END
GO

