
IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='source_deal_detail' AND COLUMN_NAME ='price_adder2')
	ALTER table source_deal_detail ADD price_adder2 FLOAT

IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='source_deal_detail' AND COLUMN_NAME ='price_adder_currency2')
	ALTER table source_deal_detail ADD price_adder_currency2 INT

IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='source_deal_detail' AND COLUMN_NAME ='volume_multiplier2')
	ALTER table source_deal_detail ADD volume_multiplier2 FLOAT

IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='source_deal_detail' AND COLUMN_NAME ='total_volume')
	ALTER table source_deal_detail ADD total_volume FLOAT


IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='source_deal_detail' AND COLUMN_NAME ='pay_opposite')
	ALTER table source_deal_detail ADD pay_opposite CHAR(1)

IF NOT EXISTS (SELECT 'x' FROM information_schema.[COLUMNS]  WHERE TABLE_NAME ='source_deal_detail_template' AND COLUMN_NAME ='pay_opposite')
	ALTER table source_deal_detail_template ADD pay_opposite CHAR(1)

