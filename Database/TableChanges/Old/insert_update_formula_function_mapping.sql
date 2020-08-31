IF EXISTS(SELECT 1 FROM formula_function_mapping WHERE function_name = 'CurveY')
BEGIN
	UPDATE formula_function_mapping SET arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)' WHERE function_name = 'CurveY'
END

DELETE FROM formula_function_mapping WHERE function_name = 'ContractPriceValue'
IF NOT EXISTS(SELECT 1 FROM formula_function_mapping WHERE function_name = 'ContractPriceValue')
BEGIN
	INSERT INTO formula_function_mapping
	(
		-- formula_function_mapping_id -- this column value is auto-generated
		function_name,
		eval_string,
		arg1,
		arg2,
		arg3,
		arg4,
		arg5,
		arg6,
		comment_function
	)
	VALUES
	(
		'ContractPriceValue',
		'dbo.FNARContractPriceValue(arg1,arg2,arg3,arg4,arg5,arg6)',
		'arg1',
		'arg2',
		'arg3',
		'convert(VARCHAR(10),t.prod_date,120)',
		'convert(VARCHAR(10),t.as_of_date,120)',
		'convert(VARCHAR,t.contract_id)',
		NULL

)
END