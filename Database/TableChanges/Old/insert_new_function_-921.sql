--select * from static_data_value where type_id=800 order By value_id 
--select * from static_data_value where type_id=27400


IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE value_id = -921)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value(value_id,type_id,code,description)
	SELECT -921,800,'PriorFinalizedVol','Get the Finalized Volume of the charge type'
	SET IDENTITY_INSERT static_data_value OFF
END


IF NOT EXISTS (SELECT 1 FROM map_function_category WHERE function_id = -921)
BEGIN
	INSERT INTO map_function_category(category_id, function_id, is_active)
	VALUES (27404, -921, 1)
END

--ContractualVolm
DELETE  FROM formula_editor_parameter WHERE formula_id =-921
IF NOT EXISTS( SELECT * FROM formula_editor_parameter AS fep WHERE fep.formula_id = -921 AND fep.field_label = 'Charge Type')
BEGIN
	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-921, 'Charge Type', 'd', '0','Charge Type','','SELECT value_id,code FROM static_data_value where type_id=10019 ORDER BY Code','0','0','','1','farrms_admin', GETDATE())
END

--select * from formula_function_mapping

IF NOT EXISTS( SELECT * FROM formula_function_mapping WHERE function_name='PriorFinalizedVol')
BEGIN
	INSERT INTO formula_function_mapping(function_name,eval_string,arg1,arg2,arg3,arg4)
	SELECT 'PriorFinalizedVol','dbo.FNARPriorFinalizedVol(CAST(arg1 AS INT),CAST(arg2 AS INT),arg3,CAST(arg4 AS INT))','CONVERT(VARCHAR,t.contract_id)','CONVERT(VARCHAR,t.counterparty_id)','CONVERT(VARCHAR(20),t.prod_date,120)','arg1'
END

--select * from formula_editor_parameter
