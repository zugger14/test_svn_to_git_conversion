IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10111500, 'Maintain Report', 'Maintain Report', 10110000, 'windowMaintainReport')
 	PRINT ' Inserted 10111500 - Maintain Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111500 - Maintain Report already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111510)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10111510, 'Maintain Report Group', 'Maintain Report Group', 10111500, 'windowMaintainReportGroup')
 	PRINT ' Inserted 10111510 - Maintain Report Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111510 - Maintain Report Group already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111511)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10111511, 'Maintain Report Detail', 'Maintain Report Detail', 10111500, 'windowMaintainReportDetails')
 	PRINT ' Inserted 10111511 - Maintain Report Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10111511 - Maintain Report Detail already EXISTS.'
END

