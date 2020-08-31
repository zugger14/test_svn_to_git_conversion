IF COL_LENGTH('index_fees_breakdown_settlement', 'shipment_id') IS NULL
BEGIN
    ALTER TABLE index_fees_breakdown_settlement ADD shipment_id INT;
END

IF COL_LENGTH('index_fees_breakdown_settlement', 'ticket_detail_id') IS NULL
BEGIN
    ALTER TABLE index_fees_breakdown_settlement ADD ticket_detail_id INT;
END

IF COL_LENGTH('source_deal_settlement', 'shipment_id') IS NULL
BEGIN
    ALTER TABLE source_deal_settlement ADD shipment_id INT;
END

IF COL_LENGTH('source_deal_settlement', 'ticket_detail_id') IS NULL
BEGIN
    ALTER TABLE source_deal_settlement ADD ticket_detail_id INT;
END
