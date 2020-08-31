IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE  function_name = 'StorageContractPrice' AND field_label = 'Deal ID' AND tooltip = 'Deal ID' )
BEGIN
	INSERT INTO formula_editor_parameter(field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, blank_option, arg_referrence_field_value_id, function_name)
	SELECT 'Deal ID', 't', NULL, 'Deal ID', 0, NULL, 0, 0, NULL, 1, 0, NULL, 'StorageContractPrice'
END

GO

IF NOT EXISTS(SELECT 1 FROM formula_editor_parameter WHERE  function_name = 'StorageContractPrice' AND field_label = 'Prod Date' AND tooltip = 'Prod Date' )
BEGIN
	INSERT INTO formula_editor_parameter(field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, blank_option, arg_referrence_field_value_id, function_name)
	SELECT 'Prod Date', 't', NULL, 'Prod Date', 0, NULL, 0, 0, NULL, 2, 0, NULL, 'StorageContractPrice'
END


--select * from update formula_editor_parameter set is_required=0 WHERE  function_name = 'StorageContractPrice' 