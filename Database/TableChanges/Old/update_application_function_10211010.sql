UPDATE application_functions
SET    function_name = 'Maintain Settlement Rules Detail IU',
       function_desc = 'Maintain Settlement Rules Detail IU',
       func_ref_id = 10211000,
       function_call = 'windowMaintainContractGroupDetail'
WHERE  [function_id] = 10211010

PRINT 'Updated Application Function '
