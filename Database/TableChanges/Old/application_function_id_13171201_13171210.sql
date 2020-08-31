IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13171201)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13171201, 'ST Forecast Mapping Group IU', 'ST Forecast Mapping Group IU', 13170000, 'windowStTermMappingGroupHeaderIU')
 	PRINT ' Inserted 13171201 - ST Forecast Mapping Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13171201 - ST Forecast Mapping Group IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13171210)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13171210, 'ST Forecast Mapping Group Delete', 'ST Forecast Mapping Group Delete', 13170000, NULL)
 	PRINT ' Inserted 13171210 - ST Forecast Mapping Group Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13171210 - ST Forecast Mapping Group Delete already EXISTS.'
END

