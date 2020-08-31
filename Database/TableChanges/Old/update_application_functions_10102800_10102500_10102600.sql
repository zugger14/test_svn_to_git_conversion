UPDATE application_functions
SET    function_call = 'windowMaintainDefinationMinor_Location'
WHERE  function_id = 10102510
	
UPDATE application_functions
SET    function_call = 'windowMinorLocationMeterData'
WHERE  function_id = 10102512
	
UPDATE application_functions
SET    function_call = 'windowMaintainDefinationPrice'
WHERE  function_id = 10102610
	
UPDATE application_functions
SET    function_call = 'windowMaintainDefinationPriceIU'
WHERE  function_id = 10102612
 	
UPDATE application_functions
SET    function_call = 'windowMaintainTimeBucketMappingIU'
WHERE  function_id = 10102614
 
UPDATE application_functions
SET    function_call = 'windowMaintainFairValueReportingGroupIU'
WHERE  function_id = 10102616


UPDATE application_functions SET func_ref_id=10103012 WHERE function_id=10221517
UPDATE application_functions SET func_ref_id=10103012 WHERE function_id=10221516
