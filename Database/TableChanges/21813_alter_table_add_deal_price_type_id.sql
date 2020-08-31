IF COL_LENGTH('deal_price_deemed','deal_price_type_id') IS NULL
	ALTER TABLE deal_price_deemed 
	ADD deal_price_type_id INT 
	REFERENCES deal_price_type(deal_price_type_id) ON DELETE CASCADE
	
IF COL_LENGTH('deal_price_std_event','deal_price_type_id') IS NULL
	ALTER TABLE deal_price_std_event 
	ADD deal_price_type_id INT 
	REFERENCES deal_price_type(deal_price_type_id) ON DELETE CASCADE
	
IF COL_LENGTH('deal_price_custom_event','deal_price_type_id') IS NULL
	ALTER TABLE deal_price_custom_event 
	ADD deal_price_type_id INT 
	REFERENCES deal_price_type(deal_price_type_id) ON DELETE CASCADE

IF COL_LENGTH('deal_detail_formula_udf','deal_price_type_id') IS NULL
	ALTER TABLE deal_detail_formula_udf 
	ADD deal_price_type_id INT 
