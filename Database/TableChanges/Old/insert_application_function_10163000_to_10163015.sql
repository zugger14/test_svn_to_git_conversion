IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163000, 'Dashboard Template', 'Dashboard Template', 10160000, 'windowDashboardTemplate')
 	PRINT ' Inserted 10163000 - Dashboard Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163000 - Dashboard Template already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163010, 'Dashboard Template Detail', 'Dashboard Template Detail', 10163000, 'windowDashboardTemplateDetail')
 	PRINT ' Inserted 10163010 - Dashboard Template Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163010 - Dashboard Template Detail already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163011)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163011, 'Dashboard Template Delete', 'Dashboard Template Delete', 10163000, NULL)
 	PRINT ' Inserted 10163011 - Dashboard Template Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163011 - Dashboard Template Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163012)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163012, 'Dashboard Template Privilege', 'Dashboard Template Privilege', 10163000, 'windowDashboardTemplatePrivilege')
 	PRINT ' Inserted 10163012 - Dashboard Template Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163012 - Dashboard Template Privilege already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163013)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163013, 'Dashboard Template Detail Filters', 'Dashboard Template Detail Filters', 10163000, 'windowDashboardTemplateDetailFilters')
 	PRINT ' Inserted 10163013 - Dashboard Template Detail Filters.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163013 - Dashboard Template Detail Filters already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163014)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163014, 'Dashboard Template Detail Options', 'Dashboard Template Detail Options', 10163000, 'windowDashboardTempleteDetailOptions')
 	PRINT ' Inserted 10163014 - Dashboard Template Detail Options.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163014 - Dashboard Template Detail Options already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163015)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163015, 'Dashboard Template Detail Add Category', 'Dashboard Template Detail Add Category', 10163000, NULL)
 	PRINT ' Inserted 10163015 - Dashboard Template Detail Add Category.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163015 - Dashboard Template Detail Add Category already EXISTS.'
END


