IF COL_LENGTH('ixp_source_deal_settlement_template', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE ixp_source_deal_settlement_template ADD settlement_date VARCHAR(400)
END
GO
IF COL_LENGTH('ixp_source_deal_settlement_template', 'volume_uom') IS NULL
BEGIN
    ALTER TABLE ixp_source_deal_settlement_template ADD volume_uom VARCHAR(400)
END
GO
IF COL_LENGTH('ixp_source_deal_settlement_template', 'fin_volume') IS NULL
BEGIN
    ALTER TABLE ixp_source_deal_settlement_template ADD fin_volume VARCHAR(400)
END
GO
IF COL_LENGTH('ixp_source_deal_settlement_template', 'fin_volume_uom') IS NULL
BEGIN
    ALTER TABLE ixp_source_deal_settlement_template ADD fin_volume_uom VARCHAR(400)
END
GO
IF COL_LENGTH('ixp_source_deal_settlement_template', 'market_value') IS NULL
BEGIN
    ALTER TABLE ixp_source_deal_settlement_template ADD market_value VARCHAR(400)
END
GO
IF COL_LENGTH('ixp_source_deal_settlement_template', 'contract_value') IS NULL
BEGIN
    ALTER TABLE ixp_source_deal_settlement_template ADD contract_value VARCHAR(400)
END
GO
IF COL_LENGTH('ixp_source_deal_settlement_template', 'set_type') IS NULL
BEGIN
    ALTER TABLE ixp_source_deal_settlement_template ADD set_type VARCHAR(400)
END
GO
IF COL_LENGTH('ixp_source_deal_settlement_template', 'allocation_volume') IS NULL
BEGIN
    ALTER TABLE ixp_source_deal_settlement_template ADD allocation_volume VARCHAR(400)
END
GO