IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183700)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10183700, 'Calc Margin Analysis', 'Calc Margin Analysis', 10180000, '_deal_verification_confirmation/calc_margin_analysis/calc.margin.analysis.php')
 	PRINT ' Inserted 10183700 - Calc Margin Analysis.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183700 - Calc Margin Analysis already EXISTS.'
END