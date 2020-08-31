IF COL_LENGTH('split_deal_detail_volume', 'bookout_id') IS NULL
BEGIN
    ALTER TABLE split_deal_detail_volume ADD bookout_id VARCHAR(5000)
END
GO


IF COL_LENGTH('deal_volume_split', 'convert_uom') IS NULL
BEGIN
    ALTER TABLE deal_volume_split ADD convert_uom INT
END
GO


IF COL_LENGTH('deal_volume_split', 'convert_frequency') IS NULL
BEGIN
    ALTER TABLE deal_volume_split ADD convert_frequency INT
END
GO

IF COL_LENGTH('split_deal_detail_volume', 'is_parent') IS NULL
BEGIN
    ALTER TABLE split_deal_detail_volume ADD is_parent CHAR(1)
END
GO
