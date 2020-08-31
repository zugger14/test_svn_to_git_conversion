IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'AVGPrice') 
BEGIN
	INSERT INTO formula_function_mapping (function_name, eval_string, arg1, arg2, arg3, arg4)
	VALUES ('AVGPrice', 'dbo.FNARAVGPrice(arg1, CAST(arg2 AS FLOAT), CAST(arg3 AS FLOAT), arg4)', 'arg1', 'arg2', 'arg3', 't.prod_date')
END
GO