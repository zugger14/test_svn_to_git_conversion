IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 12121600)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, file_path, book_required)
	VALUES (12121600, 'Assigned Hypothetical RECs', 'Assigned Hypothetical RECs', '_allowance_credit_assignment/assign.hypothetic.recs.php', 1)
END