IF NOT EXISTS (SELECT 1 FROM formula_function_mapping WHERE function_name = 'StorageContractPrice') 
BEGIN
	INSERT INTO formula_function_mapping (
		function_name,
		eval_string,
		arg1,
		arg2
	) VALUES (
		'StorageContractPrice',
		'dbo.FNARStorageContractPrice(TRY_CAST(arg1 AS INT),TRY_CAST(arg2 AS DATETIME))',
		'CONVERT(VARCHAR(20),t.source_deal_header_id)',
		'CONVERT(VARCHAR(20),t.prod_date,120)'
	)
END