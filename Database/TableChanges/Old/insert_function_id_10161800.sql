
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161800, 'Setup Plant Derate/Outage ', 'Setup Plant Derate/Outage ', 10160000, 'windowMaintainPowerOutage')
 	PRINT ' Inserted 10161800 - Setup Plant Derate/Outage .'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161800 - Setup Plant Derate/Outage  already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161810)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161810, 'Power Outage IU', 'Power Outage IU', 10161800, 'windowMaintainPowerOutageIU')
 	PRINT ' Inserted 10161810 - Power Outage IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161810 - Power Outage IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10161811)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10161811, 'Power Outage Delete', 'Power Outage Delete', 10161800, NULL)
 	PRINT ' Inserted 10161811 - Power Outage Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10161811 - Power Outage Delete already EXISTS.'
END

