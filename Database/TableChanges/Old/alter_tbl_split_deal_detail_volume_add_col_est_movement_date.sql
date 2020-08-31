

IF COL_LENGTH('split_deal_detail_volume', 'est_movement_date') IS NULL
BEGIN
    ALTER TABLE split_deal_detail_volume ADD est_movement_date DATETIME
END
GO

