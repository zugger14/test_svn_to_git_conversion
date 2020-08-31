IF NOT EXISTS( SELECT 1 FROM application_functions WHERE  function_id = 10201300)
BEGIN
    INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
    VALUES(10201300,'Maintain EoD Log Status','Maintain EoD Log Status',10200000,'')
    
    PRINT ' Inserted 10201300 - Maintain EoD Log Status.'
    
END
ELSE
BEGIN
    PRINT 'Application FunctionID 10201300 - Maintain EoD Log Status already EXISTS.'
END	

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201311)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201311, 'Maintain EoD Log Status IU', 'Maintain EoD Log Status IU', 10200000, '')
 	PRINT ' Inserted 10201311 - Maintain EoD Log Status IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201311 - Maintain EoD Log Status IU already EXISTS.'
END	

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201312)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201312, 'Maintain EoD Log Status Del', 'Maintain EoD Log Status Del', 10200000, '')
 	PRINT ' Inserted 10201312 - Maintain EoD Log Status Del.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201312 - Maintain EoD Log Status Del already EXISTS.'
END	