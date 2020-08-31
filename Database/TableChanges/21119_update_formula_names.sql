---UPDATE name of DealNetPrice 
IF EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -852
										   AND type_id = 800
										   AND code = 'DealNetPrice'
										   )
BEGIN
	UPDATE static_data_value
	SET code = 'DealSettlementPrice'
	WHERE value_id = -852
	AND type_id = 800

	UPDATE formula_function_mapping
	SET function_name = 'DealSettlementPrice',
		eval_string = REPLACE(eval_string,'DealNetPrice','DealSettlementPrice')
	WHERE function_name = 'DealNetPrice'

	UPDATE formula_editor
	SET formula = REPLACE(formula,'DealNetPrice','DealSettlementPrice')
	WHERe REPLACE(SUBSTRING(formula,0,CHARINDEX('(',formula)),'dbo.FNA','') = 'DealNetPrice'

	UPDATE formula_breakdown
	SET func_name = 'DealSettlementPrice'
	WHERE func_name = 'DealNetPrice'
END

---UPDATE name of DealVolm
IF EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -824
										   AND type_id = 800
										   AND code = 'DealVolm'
										   )
BEGIN
	UPDATE static_data_value
	SET code = 'DealTotalVolm'
	WHERE value_id = -824
	AND type_id = 800

	UPDATE formula_function_mapping
	SET function_name = 'DealTotalVolm',
		eval_string = REPLACE(eval_string,'DealVolm','DealTotalVolm')
	WHERE function_name = 'DealVolm'

	UPDATE formula_editor
	SET formula = REPLACE(formula,'DealVolm','DealTotalVolm')
	WHERe REPLACE(SUBSTRING(formula,0,CHARINDEX('(',formula)),'dbo.FNA','') = 'DealVolm'

	UPDATE formula_breakdown
	SET func_name = 'DealTotalVolm'
	WHERE func_name = 'DealVolm'
END

--UPDATE name of ContractualVolm
IF EXISTS (SELECT 1 FROM static_data_value WHERE value_id = 899
										   AND type_id = 800
										   AND code = 'ContractualVolm'
										   )
BEGIN
	UPDATE static_data_value
	SET code = 'DealVolm'
	WHERE value_id = 899
	AND type_id = 800

	UPDATE formula_function_mapping
	SET function_name = 'DealVolm',
		eval_string = REPLACE(eval_string,'ContractualVolm','DealVolm')
	WHERE function_name = 'ContractualVolm'

	UPDATE formula_editor
	SET formula = REPLACE(formula,'ContractualVolm','DealVolm')
	WHERe REPLACE(SUBSTRING(formula,0,CHARINDEX('(',formula)),'dbo.FNA','') = 'ContractualVolm'

	UPDATE formula_breakdown
	SET func_name = 'DealVolm'
	WHERE func_name = 'ContractualVolm'
END

