
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10163600, 'Flow Optimization', 'Flow Optimization', 10160000, 'windowFlowOptimization', '_scheduling_delivery/gas/flow_optimization/flow.optimization.php')
 	PRINT ' Inserted 10163600 - Flow Optimization.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163600 - Flow Optimization already EXISTS.'
END