IF NOT EXISTS (
		SELECT 1
		FROM application_functions
		WHERE function_id = 10211024
		)
BEGIN
	INSERT INTO application_functions (
		function_id
		,function_name
		,function_desc
		,func_ref_id
		,function_call
		)
	VALUES (
		10211024
		,'Contract Non Standard Contract'
		,'Contract Non Standard Contract'
		,10211000
		,'windowNonStandardContract'
		)

	PRINT ' Inserted 10211024 - Contract Non Standard Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211024 - Contract Non Standard Contract already EXISTS.'
END

IF NOT EXISTS (
		SELECT 1
		FROM application_functions
		WHERE function_id = 10211025
		)
BEGIN
	INSERT INTO application_functions (
		function_id
		,function_name
		,function_desc
		,func_ref_id
		,function_call
		)
	VALUES (
		10211025
		,'Contract Transportation Contract'
		,'Contract Transportation Contract'
		,10211000
		,'windowTransportationaContract'
		)

	PRINT ' Inserted 10211025 - Contract Transportation Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10211025 - Contract Transportation Contract already EXISTS.'
END

DELETE from application_functional_users where function_id IN (SELECT function_id from application_functions where func_ref_id=10211017)
DELETE from application_functions where func_ref_id=10211017
