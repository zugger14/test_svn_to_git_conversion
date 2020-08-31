IF COL_LENGTH('deal_volume_split_actual', 'is_complete') IS NULL
BEGIN
    ALTER TABLE deal_volume_split_actual ADD is_complete CHAR(1)
END
GO


