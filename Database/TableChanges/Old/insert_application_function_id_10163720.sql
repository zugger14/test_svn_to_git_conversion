IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163720)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10163720, 'Scheduling WorkBench Match', 'Scheduling WorkBench Match', 10163700, 'windowSchedulingWorkBenchMatch', '_scheduling_delivery/schedule_liquid_hydrocarbon_products/match.php')
 	PRINT ' Inserted 10163720 - Scheduling WorkBench Match.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163720 - Scheduling WorkBench Match already EXISTS.'
END

GO

