IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234200, 'Life Cycle of Hedges', 'Life Cycle of Hedges', 10230000, 'windowLifecyclesOfHedges')
 	PRINT ' Inserted 10234200 - Life Cycle of Hedges.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234200 - Life Cycle of Hedges already EXISTS.'
END