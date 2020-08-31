IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10201633)
BEGIN
	UPDATE sm 
		SET book_required = 1,
			func_ref_id = 10202500
	FROM application_functions AS sm WHERE sm.function_id = 10201633
	
	PRINT 'Function ID 10201633 has been saved successfully.'
END

IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10201638)
BEGIN
	UPDATE sm 
		SET func_ref_id = 10202500
	FROM application_functions AS sm WHERE sm.function_id = 10201638
	
	PRINT 'Function ID 10201638 has been saved successfully.'
END