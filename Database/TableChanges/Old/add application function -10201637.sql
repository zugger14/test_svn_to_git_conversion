IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201637)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201637, 'Report page Parameterset IU Dropdown', 'Report page Parameterset IU Dropdown', 10201622, 'windowReportParamsetIUDropdown')
 	PRINT ' Inserted 10201637 - Report page Parameterset IU Dropdown.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201637 - Report page Parameterset IU Dropdown already EXISTS.'
END
