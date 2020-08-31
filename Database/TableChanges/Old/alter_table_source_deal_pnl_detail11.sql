IF NOT EXISTS (SELECT 'x' FROM INFORMATION_SCHEMA.columns WHERE table_name='source_deal_pnl_detail' AND column_name='pay_opposite')
	alter table source_deal_pnl_detail add  fixed_cost_fx_conv_factor float,
		  formula_fx_conv_factor float,
		  price_adder1_fx_conv_factor float,
		  price_adder2_fx_conv_factor float,
		  volume_multiplier float,
		  volume_multiplier2 float,
		  price_adder2 float,
		  pay_opposite varchar(1)
