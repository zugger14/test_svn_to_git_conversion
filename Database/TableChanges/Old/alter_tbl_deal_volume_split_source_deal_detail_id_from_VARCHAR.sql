

IF COL_LENGTH('deal_volume_split', 'source_deal_detail_id_from') IS NOT NULL
BEGIN
    ALTER TABLE deal_volume_split ALTER COLUMN source_deal_detail_id_from  VARCHAR(8000)
END
GO
IF COL_LENGTH('deal_volume_split', 'source_deal_detail_id_to') IS NOT NULL
BEGIN
    ALTER TABLE deal_volume_split ALTER COLUMN source_deal_detail_id_to VARCHAR(8000)
END
GO

IF COL_LENGTH('match_group_detail', 'bookout_split_volume') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD bookout_split_volume NUMERIC(38,18)
END
GO
