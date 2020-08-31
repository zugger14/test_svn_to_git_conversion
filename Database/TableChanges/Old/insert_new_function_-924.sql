--DELETE FROM static_data_value WHERE value_id = -924
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -924)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id,type_id,code,description)
	SELECT -924,800,'GetVatAmount','Resolves vat amount'
	SET IDENTITY_INSERT static_data_value OFF
END

--DELETE FROM map_function_category WHERE function_id = -924
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -924)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (27407, -924, 1)
END


IF NOT EXISTS(SELECT * FROM formula_function_mapping WHERE function_name='GetVatAmount')
BEGIN
	INSERT INTO formula_function_mapping(function_name,eval_string,arg1, arg2, arg3)
	SELECT 'GetVatAmount','dbo.FNARGetVatAmount(cast(arg1 as int),cast(arg2 as int) ,arg3,''@process_id'')','CONVERT(VARCHAR(10),t.counterparty_id)','CONVERT(VARCHAR(10),t.contract_id)','CONVERT(VARCHAR(20),t.prod_date,120)'
END
ELSE 
BEGIN
	UPDATE formula_function_mapping
	SET
		function_name = 'GetVatAmount',
		eval_string = 'dbo.FNARGetVatAmount(cast(arg1 as int),cast(arg2 as int) ,arg3,''@process_id'')',
		arg1 = 'CONVERT(VARCHAR(10),t.counterparty_id)',
		arg2 = 'CONVERT(VARCHAR(10),t.contract_id)',
		arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)'
	WHERE function_name = 'GetVatAmount'	
END
