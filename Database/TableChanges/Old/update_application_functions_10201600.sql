/**
* updating function_name, description, function_call for function_id:10201600(from Write SSRS reports to Report Manager)
* sligal
* 9/28/2012
**/
UPDATE application_functions
SET    function_name = 'Report Manager',
       function_desc = 'Report Manager',
       func_ref_id = 10200000,
       function_call = 'windowReportManager'
WHERE  [function_id] = 10201600

PRINT 'Updated Application Function '
