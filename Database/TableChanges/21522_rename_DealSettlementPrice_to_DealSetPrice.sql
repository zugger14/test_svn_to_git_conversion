---UPDATE name of DealSettlementPrice 
IF EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -852
										   AND type_id = 800
										   AND code = 'DealSettlementPrice'
										   )
BEGIN
	UPDATE static_data_value
	SET code = 'DealSetPrice'
	WHERE value_id = -852
	AND type_id = 800

	UPDATE formula_function_mapping
	SET function_name = 'DealSetPrice',
		eval_string = REPLACE(eval_string,'DealSettlementPrice','DealSetPrice')
	WHERE function_name = 'DealSettlementPrice'

	UPDATE formula_editor
	SET formula = REPLACE(formula,'DealSettlementPrice','DealSetPrice')
	WHERe REPLACE(SUBSTRING(formula,0,CHARINDEX('(',formula)),'dbo.FNA','') = 'DealSettlementPrice'

	UPDATE formula_breakdown
	SET func_name = 'DealSetPrice'
	WHERE func_name = 'DealSettlementPrice'
END