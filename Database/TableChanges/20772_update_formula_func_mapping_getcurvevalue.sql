UPDATE formula_function_mapping 
SET arg1 = 'CONVERT(VARCHAR(10),t.prod_date,120)'
WHERE function_name = 'getcurvevalue'