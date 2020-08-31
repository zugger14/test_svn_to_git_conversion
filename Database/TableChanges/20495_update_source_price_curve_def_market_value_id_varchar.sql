UPDATE source_price_curve_def 
	SET market_value_id = NULL 
WHERE market_value_id LIKE '%[^0-9]%'