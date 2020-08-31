IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162600)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162600, 'Pipeline Imbalance Report', 'Pipeline Imbalance Report', 10160000, 'windowImbalance')
 	PRINT ' Inserted 10162600 - Pipeline Imbalance Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162600 - Pipeline Imbalance Report already EXISTS.'
END