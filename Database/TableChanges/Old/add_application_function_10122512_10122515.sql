IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122512)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122512, 'Maintain Alerts Module Event Mapping IU', 'Maintain Alerts Module Event Mapping IU', 10122500, 'windowMaintainAlertsModuleEventMappingIU')
 	PRINT ' Inserted 10122512 - Maintain Alerts Module Event Mapping IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122512 - Maintain Alerts Module Event Mapping IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122513)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122513, 'Maintain Alerts Module Event Mapping Delete', 'Maintain Alerts Module Event Mapping Delete', 10122500, 'windowMaintainAlertsModuleEventMappingDelete')
 	PRINT ' Inserted 10122513 - Maintain Alerts Module Event Mapping Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122513 - Maintain Alerts Module Event Mapping Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122514)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122514, 'Maintain Alerts Event Mapping IU', 'Maintain Alerts Event Mapping IU', 10122500, 'windowMaintainAlertsEventMappingIU')
 	PRINT ' Inserted 10122514 - Maintain Alerts Event Mapping IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122514 - Maintain Alerts Event Mapping IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122515)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10122515, 'Maintain Alerts Event Mapping Delete', 'Maintain Alerts Event Mapping Delete', 10122500, 'windowMaintainAlertsEventMappingDelete')
 	PRINT ' Inserted 10122515 - Maintain Alerts Event Mapping Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122515 - Maintain Alerts Event Mapping Delete already EXISTS.'
END

