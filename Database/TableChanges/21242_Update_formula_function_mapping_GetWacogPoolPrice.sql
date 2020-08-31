UPDATE formula_function_mapping SET arg2 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',arg3='CONVERT(VARCHAR(20), t.prod_date, 120)',arg4='CONVERT(VARCHAR(10),t.source_deal_header_id)'
WHERE  function_name = 'GetWACOGPoolPrice'



UPDATE formula_function_mapping SET eval_string = 'dbo.FNARGetWACOGPoolPrice(CAST(arg1 AS INT),CAST(arg2 as DATETIME),CAST(arg3 as DATETIME),CAST(arg4 as INT))'
WHERE  function_name = 'GetWACOGPoolPrice'