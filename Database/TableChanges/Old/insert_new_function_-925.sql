--DELETE FROM static_data_value WHERE value_id = -925
IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -925)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id,type_id,code,description)
	SELECT -925,800,'DaysInContractMnth','Returns Days in a Month considering Contract Month'
	SET IDENTITY_INSERT static_data_value OFF
END

--DELETE FROM map_function_category WHERE function_id = -925
IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -925)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (27405, -925, 1)
END

IF NOT EXISTS(SELECT * FROM formula_function_mapping WHERE function_name='DaysInContractMnth')
BEGIN
	INSERT INTO formula_function_mapping(function_name,eval_string,arg1, arg2, arg3)
	SELECT 'DaysInContractMnth','dbo.FNARDaysInContractMnth(cast(arg1 as int),cast(arg2 as int),arg3)','CONVERT(VARCHAR(10),t.contract_id)','CONVERT(VARCHAR(10),t.counterparty_id)','CONVERT(VARCHAR(20),t.prod_date,120)'
END
ELSE 
BEGIN
	UPDATE formula_function_mapping
	SET
		function_name = 'DaysInContractMnth',
		eval_string = 'dbo.FNARDaysInContractMnth(cast(arg1 as int),cast(arg2 as int),arg3)',
		arg1 = 'CONVERT(VARCHAR(10),t.contract_id)',
		arg2 = 'CONVERT(VARCHAR(10),t.counterparty_id)',
		arg3 = 'CONVERT(VARCHAR(20),t.prod_date,120)'
	WHERE function_name = 'DaysInContractMnth'	
END
