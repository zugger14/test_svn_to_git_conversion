IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10121418) 
BEGIN
	INSERT INTO application_functions
	  (
	    function_id,
	    function_name,
	    function_desc,
	    func_ref_id,
	    function_call
	  )
	VALUES
	  (
	    10121418,
	    'Maintain Vendor Setup',
	    'Maintain Vendor Setup',
	    10121400,
	    'windowSelectActivityProcessMapIU'
	  )
	PRINT 'Inserted 10121418 - Maintain Vendor Setup.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10121418 - Maintain Vendor Setup already EXISTS.'
END