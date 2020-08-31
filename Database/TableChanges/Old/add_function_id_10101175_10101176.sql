IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101175)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101175, 'Map Sub Recorder ID IU', 'Map Sub Recorder ID IU', 10101115, 'windowMaintainRecMeterID')
 	PRINT ' Inserted 10101175 - Map Sub Recorder ID IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101175 - Map Sub Recorder ID IU already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101176)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101176, 'Delete Map Sub Recorder ID', 'Delete Map Sub Recorder ID', 10101115, NULL)
 	PRINT ' Inserted 10101176 - Delete Map Sub Recorder ID.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101176 - Delete Map Sub Recorder ID already EXISTS.'
END
