IF COL_LENGTH('deal_volume_split', 'bookout_match') IS NULL
BEGIN
    ALTER TABLE deal_volume_split ADD bookout_match CHAR(1)
END
GO



