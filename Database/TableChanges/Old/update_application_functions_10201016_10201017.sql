/** updating function_id for Reprt Manager View and Report Manager View IU
* sligal
* 9/28/2012
**/

UPDATE application_functions
SET    function_id = 10201633, 
       function_name = 'Report Manager View',
       function_desc = 'Report Manager View',
       func_ref_id = 10201600,
       function_call = NULL
WHERE  [function_id] = 10201016

PRINT 'Updated Application Function '

UPDATE application_functions
SET    function_id = 10201634, 
       function_name = 'Report Manager View IU',
       function_desc = 'Report Manager View IU',
       func_ref_id = 10201600,
       function_call = NULL
WHERE  [function_id] = 10201017

PRINT 'Updated Application Function '

