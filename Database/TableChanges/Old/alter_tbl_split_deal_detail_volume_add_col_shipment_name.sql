IF COL_LENGTH('match_group_detail', 'shipment_name') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD shipment_name VARCHAR(1000)
END
GO

