UPDATE application_functions
SET    function_name = 'Maintain Settlement Rules',
       function_desc = 'Maintain Settlement Rules',
       func_ref_id = 10210000,
       function_call = 'windowMaintainContractGroup'
WHERE  [function_id] = 10211000

PRINT 'Updated Application Function '

