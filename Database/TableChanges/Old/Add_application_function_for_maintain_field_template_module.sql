DELETE FROM application_functions WHERE function_id = 10104000 AND function_name = 'Maintain Field Template'
DELETE FROM application_functions WHERE function_id = 10104010 AND function_name = 'Maintain Field Template IU'
DELETE FROM application_functions WHERE function_id = 10104011 AND function_name = 'Delete Maintain Field Template'
DELETE FROM application_functions WHERE function_id = 10104012 AND function_name = 'Copy Maintain Field Template'
DELETE FROM application_functions WHERE function_id = 10104013 AND function_name = 'Maintain Field Template Group IU'
DELETE FROM application_functions WHERE function_id = 10104014 AND function_name = 'Delete Maintain Field Template Group'

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104200, 'Maintain Field Template', 'Maintain Field Template', 10100000, 'windowSetupFieldTemplate')
 	PRINT ' Inserted 10104200 - Maintain Field Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104200 - Maintain Field Template already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104210)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104210, 'Maintain Field Template IU', 'Maintain Field Template IU', 10104200, 'windowSetupFieldTemplateIU')
 	PRINT ' Inserted 10104210 - Maintain Field Template IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104210 - Maintain Field Template IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104211)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104211, 'Delete Maintain Field Template', 'Delete Maintain Field Template', 10104200, '')
 	PRINT ' Inserted 10104211 - Delete Maintain Field Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104211 - Delete Maintain Field Template already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104212)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104212, 'Copy Maintain Field Template', 'Copy Maintain Field Template', 10104200, 'windowMaintainGroupIU')
 	PRINT ' Inserted 10104212 - Copy Maintain Field Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104212 - Copy Maintain Field Template already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104213)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104213, 'Maintain Field Template Group IU', 'Maintain Field Template Group IU', 10104200, '')
 	PRINT ' Inserted 10104213 - Maintain Field Template Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104213 - Maintain Field Template Group IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104214)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104214, 'Delete Maintain Field Template Group', 'Delete Maintain Field Template Group', 10104200, 'windowSetupFieldTemplateAdd')
 	PRINT ' Inserted 10104214 - Delete Maintain Field Template Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104214 - Delete Maintain Field Template Group already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104215)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104215, 'Maintain Field Template Header', 'Maintain Field Template Header', 10104200, 'windowSetupFieldTemplateAdd')
 	PRINT ' Inserted 10104215 - Maintain Field Template Header.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104215 - Maintain Field Template Header already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104216)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104216, 'Maintain Field Template Detail', 'Maintain Field Template Detail', 10104200, 'windowSetupFieldTemplateAddDetail')
 	PRINT ' Inserted 10104216 - Maintain Field Template Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104216 - Maintain Field Template Detail already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104217)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104217, 'Add Maintain Field Template Header', 'Add Maintain Field Template Header', 10104215, '')
 	PRINT ' Inserted 10104217 - Add Maintain Field Template Header.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104217 - Add Maintain Field Template Header already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104218)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104218, 'Save Maintain Field Template Header', 'Save Maintain Field Template Header', 10104215, '')
 	PRINT ' Inserted 10104218 - Save Maintain Field Template Header.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104218 - Save Maintain Field Template Header already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104219)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104219, 'Add Maintain Field Template Detail', 'Add Maintain Field Template Detail', 10104216, '')
 	PRINT ' Inserted 10104219 - Add Maintain Field Template Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104219 - Add Maintain Field Template Detail already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104220)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10104220, 'Save Maintain Field Template Header', 'Save Maintain Field Template Header', 10104216, '')
 	PRINT ' Inserted 10104220 - Save Maintain Field Template Header.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104220 - Save Maintain Field Template Header already EXISTS.'
END
