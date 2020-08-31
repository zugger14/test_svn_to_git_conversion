IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163900)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10163900, 'Route Group', 'Route Group', 10160000, 'windowRouteGroup')
 	PRINT ' Inserted 10163900 - Route Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163900 - Route Group already EXISTS.'
END

GO

UPDATE application_functions
SET file_path = '_scheduling_delivery/gas/route_group/route.group.php'
WHERE function_id = 10163900

GO