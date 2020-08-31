IF NOT EXISTS(SELECT 1 FROM formula_function_mapping WHERE function_name = 'PriceAdder')
BEGIN
	INSERT INTO formula_function_mapping
	(
		function_name,
		eval_string,
		arg1,
		arg2,
		arg3,
		arg4,
		arg5,
		arg6
	)
	VALUES
	(
		'PriceAdder',
		'dbo.FNARPriceAdder(arg1, CAST(arg2 AS INT), CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT), CAST(arg6 AS INT))',
		'CONVERT(VARCHAR(20), t.prod_date, 120)',
		'CONVERT(VARCHAR, t.counterparty_id)',
		'CONVERT(VARCHAR, t.contract_id)',
		'CONVERT(VARCHAR, t.source_deal_detail_id)',
		'CONVERT(VARCHAR(10), ISNULL(t.source_deal_header_id, sdd.source_deal_header_id))',
		'CONVERT(VARCHAR, t.calc_aggregation)'
	)
END