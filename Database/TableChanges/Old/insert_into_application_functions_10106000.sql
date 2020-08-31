IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10106000, 'Nomination Group', 'Nomination Group', 10100000, 'windowNominationGroup', '_scheduling_delivery/gas/nominaiton_group/nomination.group.php')
 	PRINT ' Inserted 10106000 - Nomination Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106000 - Nomination Group already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10106010, 'Nomination Group IU', 'Nomination Group IU', 10106000, 'windowNominationGroupIU', '')
 	PRINT ' Inserted 10106010 - Nomination Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106010 - Nomination Group already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10106011)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10106011, 'Nomination Group Delete', 'Nomination Group Delete', 10106000, '', '')
 	PRINT ' Inserted 10106011 - Nomination Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10106011 - Nomination Group already EXISTS.'
END

--select * from application_functions where function_id = 10106000
--update application_functions set file_path = '_scheduling_delivery/gas/nominaiton_group/ ' where function_id = 10106000