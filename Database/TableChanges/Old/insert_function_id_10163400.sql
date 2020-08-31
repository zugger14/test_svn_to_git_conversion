IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call,file_path)
	VALUES (10163400, 'Schedules View', 'Schedules View', 10160000, 'windowSchedulesView','_scheduling_delivery/gas/view_nom_schedules/view.nom.schedules.php')
 	PRINT ' Inserted 10163400 - Schedules View.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163400 - Schedules View already EXISTS.'
END



