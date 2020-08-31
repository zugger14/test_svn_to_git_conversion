IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201700)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201700, 'Run Report Group', 'Run Report Group', 10200000, 'WindowRunReportGroup')
 	PRINT ' Inserted 10201700 - Run Report Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201700 - Run Report Group already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201800, 'Report Group Manager', 'Report Group Manager', 10200000, 'WindowReportGroupManager')
 	PRINT ' Inserted 10201800 - Report Group Manager.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201800 - Report Group Manager already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201810)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201810, 'Report Group Manager Name IU', 'Report Group Manager Name IU', 10201800, NULL)
 	PRINT ' Inserted 10201810 - Report Group Manager Name IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201810 - Report Group Manager Name IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201811)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201811, 'Report Group Manager Name Delete', 'Report Group Manager Name Delete', 10201800, NULL)
 	PRINT ' Inserted 10201811 - Report Group Manager Name Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201811 - Report Group Manager Name Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201812)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201812, 'Report Group Manager IU', 'Report Group Manager IU', 10201800, NULL)
 	PRINT ' Inserted 10201812 - Report Group Manager IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201812 - Report Group Manager IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201813)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201813, 'Report Group Manager Delete', 'Report Group Manager Delete', 10201800, NULL)
 	PRINT ' Inserted 10201813 - Report Group Manager Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201813 - Report Group Manager Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201814)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201814, 'Report Group Manager Parameter IU', 'Report Group Manager Parameter IU', 10201800, NULL)
 	PRINT ' Inserted 10201814 - Report Group Manager Parameter IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201814 - Report Group Manager Parameter IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201815)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201815, 'Report Group Manager Parameter Delete', 'Report Group Manager Parameter Delete', 10201800, NULL)
 	PRINT ' Inserted 10201815 - Report Group Manager Parameter Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201815 - Report Group Manager Parameter Delete already EXISTS.'
END
