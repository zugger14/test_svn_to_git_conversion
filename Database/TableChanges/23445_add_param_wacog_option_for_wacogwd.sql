UPDATE formula_function_mapping 
SET eval_string = 'dbo.FNARWACOGWD(arg1, arg2)',
	arg2 = 'arg1'
WHERE function_name = 'WACOGWD'

IF NOT EXISTS (SELECT 1 FROM formula_editor_parameter WHERE function_name = 'WACOGWD' AND field_label = 'WACOG Option')
BEGIN
	INSERT INTO formula_editor_parameter (field_label, field_type, tooltip, field_size, sql_string, is_required, is_numeric, sequence, blank_option, function_name)
	VALUES ('WACOG Option', 'd', 'WACOG Option',  0, 'EXEC spa_StaticDataValues @flag=h, @type_id=110500', 1, 0, 1, 0, 'WACOGWD')
END
ELSE
BEGIN
	UPDATE formula_editor_parameter 
	SET default_value = 110500
	WHERE function_name = 'WACOGWD' AND field_label = 'WACOG Option'
END

UPDATE map_function_category
SET is_active = 1
WHERE function_name = 'WACOGWD'

GO