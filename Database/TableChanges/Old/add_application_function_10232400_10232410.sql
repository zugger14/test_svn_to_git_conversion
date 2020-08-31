IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id =  10232400)  
BEGIN     
	INSERT INTO application_functions   (function_id, function_name, function_desc, func_ref_id, requires_at, document_path, function_call, function_parameter, module_type, create_user)   
	VALUES   (    10232400,'View Assessment Results','View Assessment Results','13110000',NULL,'Assessment of Hedge Effectiveness/View Assessment Results.htm','windowViewAssessmentResults',NULL,NULL,'farrms_admin')  
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232410) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10232410, 'Assesment Result IU', 'Assesment Result IU', 10232400,'windowViewAssessmentResultsIU')
	PRINT '10232410 INSERTED'
END 
