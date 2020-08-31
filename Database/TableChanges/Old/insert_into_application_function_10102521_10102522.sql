IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102521)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10102521, 'Source Minor Location Rank IU', 'Source Minor Location Rank IU', 10102510, '')
 	PRINT ' Inserted 10102521 - Source Minor Location Rank IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102521 - Source Minor Location Rank IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102522)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10102522, 'Source Minor Location RankDelete', 'Source Minor Location RankDelete', 10102510, '')
 	PRINT ' Inserted 10102522 - Source Minor Location RankDelete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102522 - Source Minor Location RankDelete already EXISTS.'
END