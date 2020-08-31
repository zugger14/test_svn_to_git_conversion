UPDATE formula_function_mapping
	SET eval_string = '[dbo].[FNARRateScheduleFee](arg1,cast(arg2  as INT),cast(arg3  as INT),cast(arg4  as INT),arg5)', 
	arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
	arg2 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
	arg3 = 'CONVERT(VARCHAR,t.contract_id)',
	arg4 = 'arg1',
	arg5 = 'CONVERT(VARCHAR(20),prod_date,120)'
WHERE function_name = 'RateScheduleFee'

