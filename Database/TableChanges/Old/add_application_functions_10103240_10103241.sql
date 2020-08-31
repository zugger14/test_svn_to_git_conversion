IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103240)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103240, 'Pratos Mapping Profile Meter Mapping IU', 'Pratos Mapping Profile Meter Mapping IU', 10103200, 'windowPratosMappingProfileMeterMappingIU')
 	PRINT ' Inserted 10103240 - Pratos Mapping Profile Meter Mapping IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103240 - Pratos Mapping Profile Meter Mapping IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103241)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103241, 'Delete Pratos Mapping Profile Meter Mapping', 'Delete Pratos Mapping Profile Meter Mapping', 10103200, NULL)
 	PRINT ' Inserted 10103241 - Delete Pratos Mapping Profile Meter Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103241 - Delete Pratos Mapping Profile Meter Mapping already EXISTS.'
END
