---Function ids for Maintain Field template
--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104000)
--BEGIN
-- 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
--	VALUES (10104000, 'Maintain Field Template', 'Maintain Field Template', 10100000, 'windowSetupFieldTemplate')
-- 	PRINT ' Inserted 10104000 - Maintain Field Template.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10104000 - Maintain Field Template already EXISTS.'
--END

--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104010)
--BEGIN
-- 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
--	VALUES (10104010, 'Maintain Field Template IU', 'Maintain Field Template IU', 10104000, 'windowSetupFieldTemplateIU')
-- 	PRINT ' Inserted 10104010 - Maintain Field Template IU.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10104010 - Maintain Field Template IU already EXISTS.'
--END

--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104011)
--BEGIN
-- 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
--	VALUES (10104011, 'Delete Maintain Field Template', 'Delete Maintain Field Template', 10104000, '')
-- 	PRINT ' Inserted 10104011 - Delete Maintain Field Template.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10104011 - Delete Maintain Field Template already EXISTS.'
--END

--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104012)
--BEGIN
-- 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
--	VALUES (10104012, 'Copy Maintain Field Template', 'Copy Maintain Field Template', 10104000, '')
-- 	PRINT ' Inserted 10104012 - Copy Maintain Field Template.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10104012 - Copy Maintain Field Template already EXISTS.'
--END

--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104013)
--BEGIN
-- 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
--	VALUES (10104013, 'Maintain Field Template Group IU', 'Maintain Field Template Group IU', 10104000, 'windowMaintainGroupIU')
-- 	PRINT ' Inserted 10104013 - Maintain Field Template Group IU.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10104013 - Maintain Field Template Group IU already EXISTS.'
--END

--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104014)
--BEGIN
-- 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
--	VALUES (10104014, 'Delete Maintain Field Template Group', 'Delete Maintain Field Template Group', 10104000, '')
-- 	PRINT ' Inserted 10104014 -Delete Maintain Field Template Group.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10104014 - Delete Maintain Field Template Group already EXISTS.'
--END

---Function ids for Maintain UDF Template
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104100)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104100, 'Maintain UDF Template', 'Maintain UDF Template', 10100000, 'windowSetupUDFTemplate')
 	PRINT ' Inserted 10104014 -Maintain UDF Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104100 - Maintain UDF Template already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104110)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104110, 'Maintain UDF Template IU', 'Maintain UDF Template IU', 10104100, 'windowSetupUDFTemplateDetailIU')
 	PRINT ' Inserted 10104110 -Maintain UDF Template IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104110 - Maintain UDF Template IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104111)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10104111, 'Delete Maintain UDF Template', 'Delete Maintain UDF Template', 10104100, '')
 	PRINT ' Inserted 10104111 -Delete Maintain UDF Template.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10104111 - Delete Maintain UDF Template already EXISTS.'
END