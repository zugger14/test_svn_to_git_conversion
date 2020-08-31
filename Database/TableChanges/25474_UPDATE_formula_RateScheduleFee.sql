DELETE FROM formula_editor_parameter WHERE function_name = 'RateScheduleFee' AND field_label <> 'UDF Charges'

UPDATE fep 
	SET sequence = 1,
	sql_string = 'SELECT sdv.value_id,sdv.code FROM static_data_value sdv INNER JOIN user_defined_fields_template udft ON sdv.value_id = udft.field_name INNER JOIN static_data_value sdv1 ON sdv1.value_id = udft.udf_category and udft.udf_category IN (101901,101900) WHERE sdv.type_id=5500 ORDER BY code'
FROM formula_editor_parameter fep
WHERE function_name = 'RateScheduleFee' 
AND field_label = 'UDF Charges'

UPDATE formula_function_mapping
	SET eval_string = '[dbo].[FNARRateScheduleFee](arg1,cast(arg2  as INT),cast(arg3  as INT),cast(arg4  as INT))', 
	arg1 = 'CONVERT(VARCHAR(20),t.as_of_date,120)',
	arg2 = 'CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))',
	arg3 = 'CONVERT(VARCHAR,t.contract_id)',
	arg4 = 'arg1'
WHERE function_name = 'RateScheduleFee'

