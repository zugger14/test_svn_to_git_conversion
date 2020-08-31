IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12103200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103200, 'Setup REC Assignment Priority', 'Setup REC Assignment Priority', NULL, '')
 	PRINT ' Inserted 12103200 - Setup REC Assignment Priority.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12103200 - Setup REC Assignment Priority already EXISTS.'
END
GO
UPDATE application_functions
SET file_path = '_compliance_management/setup_rec_assignment_priority/setup.rec.assignment.priority.php'
WHERE function_id = 12103200
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12103210)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103210, 'Group Add/Save', 'Setup REC Assignment Priority Group IU', 12103200, '')
 	PRINT ' Inserted 12103210 - Setup REC Assignment Priority Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12103210 - Setup REC Assignment Priority Group IU already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12103211)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103211, 'Group Delete', 'Setup REC Assignment Priority Group Del', 12103200, '')
 	PRINT ' Inserted 12103211 - Setup REC Assignment Priority Group Del.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12103211 - Setup REC Assignment Priority Group Del already EXISTS.'
END
GO
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12103212)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103212, 'Detail Add/Save', 'Setup REC Assignment Priority Detail IU', 12103200, '')
 	PRINT ' Inserted 12103212 - Setup REC Assignment Priority Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12103212 - Setup REC Assignment Priority Detail IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12103213)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103213, 'Detail Delete', 'Setup REC Assignment Priority Detail Del', 12103200, '')
 	PRINT ' Inserted 12103213 - Setup REC Assignment Priority Detaqil Del.'
END
ELSE
BEGIN
	update application_functions
	set function_name = 'Detail Delete'
	where function_id = 12103213
	PRINT 'Application FunctionID 12103213 - Setup REC Assignment Priority Detaqil Del already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12103214)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103214, 'Order Add/Save', 'Setup REC Assignment Priority Order IU', 12103200, '')
 	PRINT ' Inserted 12103214 - Setup REC Assignment Priority Order Del.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12103214 - Setup REC Assignment Priority Order Del already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 12103215)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103215, 'Order Delete', 'Setup REC Assignment Priority Order Del', 12103200, '')
 	PRINT ' Inserted 12103215 - Setup REC Assignment Priority Order Del.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 12103215 - Setup REC Assignment Priority Order Del already EXISTS.'
END

--select * FROM application_functions WHERE func_ref_id = 12103200
--SELECT * FROM  application_functions af WHERE af.function_id =  12103200