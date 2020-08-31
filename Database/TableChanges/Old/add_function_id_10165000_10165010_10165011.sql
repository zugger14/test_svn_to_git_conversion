
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10165000)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id,function_call, file_path)
	SELECT 10165000, 'Assign Priority to Nomination Group Menu', 'Assign Priority to Nomination Group Menu', 10160000,'windowNominationGroup', '_scheduling_delivery/gas/nominaiton_group/nomination.group.php'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10165010)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id,function_call, file_path)
	SELECT 10165010, 'Assign Priority to Nomination Group Add/Save ', 'Assign Priority to Nomination Group Add/Save', 10165000,'windowNominationGroupUI', ''
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10165011)
BEGIN
	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id,function_call, file_path)
	SELECT 10165011, 'Assign Priority to Nomination Group Delete', 'Assign Priority to Nomination Group Delete', 10165000,'', ''
END
GO


