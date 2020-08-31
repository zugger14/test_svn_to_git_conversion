-- Update book_required 1 for Maintain Limit UI
IF EXISTS(SELECT * FROM application_functions WHERE function_id = 10181300)
BEGIN
	UPDATE application_functions SET book_required = 1 WHERE function_id = 10181300
END

-- Update book_required 1 for Run At Risk Measurement UI
IF EXISTS(SELECT * FROM application_functions WHERE function_id = 10181200)
BEGIN
	UPDATE application_functions SET book_required = 1 WHERE function_id = 10181200
END

-- Update book_required 1 for Setup Portfolio Group UI
IF EXISTS(SELECT * FROM application_functions WHERE function_id = 10183200)
BEGIN
	UPDATE application_functions SET book_required = 1 WHERE function_id = 10183200
END

-- Update book_required 1 for Run What If Analysis UI
IF EXISTS(SELECT * FROM application_functions WHERE function_id = 10183400)
BEGIN
	UPDATE application_functions SET book_required = 1 WHERE function_id = 10183400
END

-- Update book_required 1 for Run MTM Simulation UI
IF EXISTS(SELECT * FROM application_functions WHERE function_id = 10184000)
BEGIN
	UPDATE application_functions SET book_required = 1 WHERE function_id = 10184000
END

-- Update book_required 1 for Run MTM Process UI
IF EXISTS(SELECT * FROM application_functions WHERE function_id = 10181000)
BEGIN
	UPDATE application_functions SET book_required = 1 WHERE function_id = 10181000
END