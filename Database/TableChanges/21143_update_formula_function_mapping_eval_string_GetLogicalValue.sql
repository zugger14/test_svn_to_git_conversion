UPDATE formula_function_mapping
	SET eval_string = 'dbo.FNARGetLogicalValue(CAST(arg1 AS INT),arg2, CAST(arg3 AS INT), CAST(arg4 AS INT))'
WHERE function_name = 'GetLogicalValue'
