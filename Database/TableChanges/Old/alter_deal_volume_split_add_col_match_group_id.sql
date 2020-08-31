IF COL_LENGTH('deal_volume_split', 'match_group_id') IS NULL
BEGIN
    ALTER TABLE deal_volume_split ADD match_group_id INT
END
GO

