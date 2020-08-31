IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10183400)
BEGIN
	INSERT INTO application_functions 
	(
		function_id,
		function_name,
		function_desc,
		func_ref_id,
		function_call,
		file_path,
		book_required
	)
	VALUES
	(
		10183400,
		'Setup What if Criteria',
		'Setup What if Criteria',
		10183499,
		'windowSetupWhatIfCriteria',
		'_valuation_risk_analysis/maintain_whatif_criteria/maintain.whatif.criteria.php',
		0
	)
	PRINT 'application function inserted successfully.'
END
ELSE
BEGIN
	PRINT 'application function already exist.'
END