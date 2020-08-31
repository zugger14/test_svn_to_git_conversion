IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10211415)
BEGIN 
UPDATE
	application_functions
	SET
	func_ref_id = 10211300
	WHERE
	function_id = 10211415
END
ELSE
	Print 'Function_id does not exists.'