IF EXISTS(SELECT 1 FROM formula_editor_parameter WHERE function_name = 'ActualizedQualityValue' AND field_label = 'Quality')                                                                                                       
BEGIN
 	UPDATE formula_editor_parameter
	SET sequence = 1
	WHERE function_name = 'ActualizedQualityValue'
	AND field_label = 'Quality'
END

IF EXISTS(SELECT 1 FROM formula_editor_parameter WHERE function_name = 'ContractualQualityValue' AND field_label = 'Quality')                                                                                                       
BEGIN
 	UPDATE formula_editor_parameter
	SET sequence = 1
	WHERE function_name = 'ContractualQualityValue'
	AND field_label = 'Quality'
END
