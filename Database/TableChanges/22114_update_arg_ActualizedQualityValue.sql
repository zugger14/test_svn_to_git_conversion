UPDATE dbo.formula_function_mapping
SET arg1 = 'arg1',
	arg2 = 'CONVERT(VARCHAR, t.source_deal_detail_id)',
	eval_string = 'dbo.FNARActualizedQualityValue(CAST(arg1 AS NUMERIC), CAST(arg2 AS INT))'
 WHERE function_name = 'ActualizedQualityValue'

UPDATE dbo.formula_function_mapping
SET arg1 = 'arg1',
	arg2 = 'CONVERT(VARCHAR, t.source_deal_detail_id)',
	eval_string = 'dbo.FNARContractualQualityValue(CAST(arg1 AS NUMERIC), CAST(arg2 AS INT))'
WHERE function_name = 'ContractualQualityValue'
GO