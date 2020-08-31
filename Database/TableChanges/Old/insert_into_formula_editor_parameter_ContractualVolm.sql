--ContractualVolm
DELETE  FROM formula_editor_parameter WHERE formula_id =899
IF NOT EXISTS( SELECT * FROM formula_editor_parameter AS fep WHERE fep.formula_id = 899 AND fep.field_label = 'Value')
BEGIN
	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (899, 'Value', 'd', '0','value','','SELECT 0 as [Value], 0 as [Text] UNION SELECT 1,1','0','0','','1','farrms_admin', GETDATE())
END

