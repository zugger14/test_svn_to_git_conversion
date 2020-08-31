
ALTER TABLE source_deal_pnl_detail ADD
	[curve_as_of_date] datetime NULL,
	[internal_deal_type_value_id] INT  NULL,
	[internal_deal_subtype_value_id] INT  NULL,
	curve_uom_conv_factor INT NULL,
	curve_fx_conv_factor INT NULL,
	price_fx_conv_factor INT NULL,
    curve_value FLOAT NULL,
	fixed_cost float NULL,
	fixed_price float NULL,
	formula_value float NULL,
	price_adder float NULL,
	price_multiplier float NULL,
	strike_price float NULL,
	buy_sell_flag varchar(1)
