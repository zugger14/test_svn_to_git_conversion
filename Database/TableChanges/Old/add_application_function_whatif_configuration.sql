/**
* sligal
* date: 29 oct 2013
* purpose: added application function for valuation and risk analysis module for menu whatif configuration (f10 menu)
**/

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183414)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10183414, 'Whatif Configuration', 'Whatif Configuration', 10183400, 'windowWhatifConfiguration')
 	PRINT ' Inserted 10183414 - Whatif Configuration.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183414 - Whatif Configuration already EXISTS.'
END
