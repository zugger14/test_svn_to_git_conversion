IF COL_LENGTH('deal_detail_formula_udf','formula_id') IS NULL
	ALTER TABLE deal_detail_formula_udf 
	ADD formula_id INT 
