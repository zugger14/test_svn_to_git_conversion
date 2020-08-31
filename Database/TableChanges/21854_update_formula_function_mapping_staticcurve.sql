UPDATE formula_function_mapping 
SET arg5 = 'convert(VARCHAR,t.hour)',
	arg6 = 'convert(VARCHAR,t.mins)',
	arg7 = 'convert(VARCHAR,t.is_dst)',
	eval_string= 'dbo.FNARStaticCurve(arg1,arg2,NULL,cast(arg4 as INT),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int))'
WHERE function_name = 'staticcurve'
