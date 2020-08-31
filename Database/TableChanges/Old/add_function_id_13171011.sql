IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 13171011)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (13171011, 'ST Forecast Mapping Detail IU', 'ST Forecast Mapping Detail IU', 13171000, 'windowStTermMappingGroupIU')
 	PRINT ' Inserted 13171011 - ST Forecast Mapping Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 13171011 - ST Forecast Mapping Detail IU already EXISTS.'
END
