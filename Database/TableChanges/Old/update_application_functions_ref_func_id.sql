IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101099)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101099,'Setup Static Data','Setup Static Data',10100000,'')
	PRINT '10101099 INSERTED'
END


UPDATE application_functions SET func_ref_id = 10101099  WHERE function_id IN (
10101000,
10101200,
10102600,
10102500,
10105800)



IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10221099)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10221099,'Run Settlement Calc','Run Settlement Calc',10220000,'')
	PRINT '10221099 INSERTED'
END


UPDATE application_functions SET func_ref_id = 10101099  WHERE function_id IN (
10222300,
10221300,
10221000
)