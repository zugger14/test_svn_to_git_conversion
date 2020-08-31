
UPDATE formula_function_mapping SET
eval_string = 'CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARGetCurveValueSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),wif.curve_shift_val  ,@curve_shift_per) ELSE dbo.FNARGetCurveValue(TRY_CAST(arg1 AS INT) ,arg2,arg3, CAST(NULLIF(arg4,''NULL'') AS FLOAT),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),wif.curve_shift_val  ,wif.curve_shift_per) END'
,arg1 = 'CASE WHEN ''@calc_type''=''s'' THEN cast(isnull(spcd_s.settlement_curve_id,f.arg1) as varchar) ELSE arg1 END'
,arg2 = 'CONVERT(VARCHAR(10),t.prod_date,120)'
,arg3 = 'convert(VARCHAR(20),t.as_of_date,120)' 
WHERE function_name = 'getcurvevalue'
 
