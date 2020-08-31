IF COL_LENGTH('source_deal_settlement_breakdown', 'must_run_volume') IS NULL
BEGIN
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD must_run_volume numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD dispatch_volume numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD must_run_market_value numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD must_run_contract_value numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD dispatch_market_value numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD dispatch_contract_value numeric(18,6)


	ALTER TABLE dbo.source_deal_settlement_breakdown ADD market_value_deal numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD contract_value_deal numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD simple_formula_curve_value_deal numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD market_value_inv numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD contract_value_inv numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD simple_formula_curve_value_inv numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD formula_conv_factor_inv numeric(18,6)
	ALTER TABLE dbo.source_deal_settlement_breakdown ADD formula_conv_factor_deal numeric(18,6)


END

	
