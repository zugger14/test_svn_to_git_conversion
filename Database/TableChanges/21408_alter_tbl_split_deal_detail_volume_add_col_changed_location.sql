IF COL_LENGTH('split_deal_detail_volume', 'changed_location') IS NULL
BEGIN
    ALTER TABLE split_deal_detail_volume ADD changed_location INT
END
GO



 