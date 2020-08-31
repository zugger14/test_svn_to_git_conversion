IF COL_LENGTH('match_group_shipment', 'shipment_status') IS NULL
BEGIN
    ALTER TABLE match_group_shipment ADD shipment_status CHAR(1)
END
GO

IF COL_LENGTH('match_group_shipment', 'from_location') IS NULL
BEGIN
    ALTER TABLE match_group_shipment ADD from_location INT
END
GO


IF COL_LENGTH('match_group_shipment', 'to_location') IS NULL
BEGIN
    ALTER TABLE match_group_shipment ADD to_location INT
END
GO



IF COL_LENGTH('match_group_shipment', 'is_transport_deal_created') IS NULL
BEGIN
    ALTER TABLE match_group_shipment ADD is_transport_deal_created INT
END
GO
