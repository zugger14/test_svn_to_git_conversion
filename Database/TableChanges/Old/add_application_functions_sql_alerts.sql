IF EXISTS(SELECT 1 FROM application_functions WHERE function_id IN (10111600, 10111610, 10111611))
BEGIN
	DELETE FROM application_functions WHERE function_id IN (10111600, 10111610, 10111611)
END

IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 10122500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10122500, 'Maintain Alerts', 'Maintain Alerts', 10120000, 'windowMaintainAlerts')
 	PRINT ' Inserted 10122500 - Maintain Alerts.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122500 - Maintain Alerts already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122510)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10122510, 'Maintain Alerts IU', 'Maintain Alerts IU', 10122500, 'windowMaintainAlertsIU')
 	PRINT ' Inserted 10122510 - Maintain Alerts IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122510 - Maintain Alerts IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10122511)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10122511, 'Maintain Alerts Delete', 'Maintain Alerts Delete', 10122500, 'windowMaintainAlertsDelete')
 	PRINT ' Inserted 10122511 - Maintain Alerts Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10122511 - Maintain Alerts Delete already EXISTS.'
END

