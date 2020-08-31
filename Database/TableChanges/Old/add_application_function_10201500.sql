IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201500, 'Run Static Data Audit Report', 'Run Static Data Audit Report', 10200000, 'windowRunStaticDataAuditReport')
 	PRINT ' Inserted 10201500 - Run Static Data Audit Report.'
END
ELSE
BEGIN
	PRINT 'Application Function ID 10201500 - Run Static Data Audit Report already EXISTS.'
END	


