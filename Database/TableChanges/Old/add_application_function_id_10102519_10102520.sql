/*
insert function ids for setup location detail route ui and delete.
2015-04-21
*/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102519)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10102519, 'Source Minor Location Route IU', 'Source Minor Location Route IU', 10102510, 'windowSetupLocationRouteIU')
 	PRINT ' Inserted 10102519 - Source Minor Location Route IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102519 - Source Minor Location Route IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102520)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10102520, 'Source Minor Location Route Delete', 'Source Minor Location Route Delete', 10102510, 'windowSetupLocationRouteDelete')
 	PRINT ' Inserted 10102520 - Source Minor Location Route Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102520 - Source Minor Location Route Delete already EXISTS.'
END
