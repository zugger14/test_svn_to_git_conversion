IF COL_LENGTH('split_deal_detail_volume', 'est_movement_date_to') IS NULL
BEGIN
    ALTER TABLE split_deal_detail_volume ADD est_movement_date_to DATETIME
END
GO

