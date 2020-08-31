
IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10190000 AND func_ref_id = 10000000) 
INSERT INTO application_functions
(
	function_id,
	function_name,
	function_desc,
	func_ref_id
)
VALUES
(
	10190000,
	'Credit Risk And Analysis',
	'Credit Risk And Analysis',
	10000000
)
ELSE
	PRINT 'Application function Id 10190000 of reference Id 10000000 already exists.'
	
-------------------------------------------------------------------------------------
	
IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10191800 AND func_ref_id =10190000) 	
INSERT INTO application_functions
(
	function_id,
	function_name,
	function_desc,
	func_ref_id
)
VALUES
(
	10191800,
	'Calculate Credit Exposure',
	'Calculate Credit Exposure',
	10190000
)
ELSE 
	PRINT 'Application function Id 10191800 of reference Id 10190000 already exists.'


