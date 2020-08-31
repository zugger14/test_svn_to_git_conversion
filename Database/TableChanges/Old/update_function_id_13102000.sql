UPDATE application_functions
SET    function_name = 'Generic Mapping',
       function_desc = 'Generic Mapping',
       func_ref_id = 10100000,
       function_call = 'windowGenericMapping'
WHERE  [function_id] = 13102000

PRINT 'Updated Application Function '