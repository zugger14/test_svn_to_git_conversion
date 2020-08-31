IF COL_LENGTH('deal_pricing_filter','predefined_formula_form_json') IS NULL
	ALTER TABLE deal_pricing_filter 
	ADD predefined_formula_form_json VARCHAR(MAX) 

IF COL_LENGTH('deal_pricing_filter','price_adjustment') IS NULL
	ALTER TABLE deal_pricing_filter 
	ADD price_adjustment VARCHAR(MAX) 


