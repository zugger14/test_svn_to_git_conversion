IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='multiplier')
ALTER TABLE source_deal_detail_audit ADD multiplier	FLOAT

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='adder_currency_id')
ALTER TABLE source_deal_detail_audit ADD adder_currency_id	int

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='fixed_cost_currency_id')
ALTER TABLE source_deal_detail_audit ADD fixed_cost_currency_id	int

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='formula_currency_id')
ALTER TABLE source_deal_detail_audit ADD formula_currency_id	int

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='price_adder2')
ALTER TABLE source_deal_detail_audit ADD price_adder2	float

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='price_adder_currency2')
ALTER TABLE source_deal_detail_audit ADD price_adder_currency2	int

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='volume_multiplier2')
ALTER TABLE source_deal_detail_audit ADD volume_multiplier2	float

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='total_volume')
ALTER TABLE source_deal_detail_audit ADD total_volume	float

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='pay_opposite')
ALTER TABLE source_deal_detail_audit ADD pay_opposite	VARCHAR(1)

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='formula_text')
ALTER TABLE source_deal_detail_audit ADD formula_text	VARCHAR(MAX)

IF NOT EXISTS (SELECT * FROM information_schema.columns WHERE table_name ='source_deal_detail_audit' AND column_name='capacity')
ALTER TABLE source_deal_detail_audit ADD capacity	float
