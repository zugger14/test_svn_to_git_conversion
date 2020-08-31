
IF COL_LENGTH('source_deal_settlement_breakdown', 'org_term') IS NULL
BEGIN
	alter table dbo.source_deal_pnl_breakdown add org_term datetime,[org_hours] int,[org_is_dst] int,
		timezone_from_id int,timezone_to_id int	 , simple_formula_curve_value float
	alter table dbo.source_deal_settlement_breakdown add org_term datetime,[org_hours] int,[org_is_dst] int,
		timezone_from_id int,timezone_to_id int	 , simple_formula_curve_value float
END
