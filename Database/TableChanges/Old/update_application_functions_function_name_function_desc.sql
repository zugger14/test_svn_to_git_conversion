--SELECT * FROM application_functions WHERE function_id = 10162000
--SELECT * FROM application_functions WHERE function_id = 10161300
--SELECT * FROM application_functions WHERE function_id = 10161312


UPDATE application_functions
SET    function_name = 'Maintain Rate Schedule',
       function_desc = 'Maintain Rate Schedule'
WHERE  function_id = 10162000


UPDATE application_functions
SET    function_name = 'View Delivery Schedules',
       function_desc = 'View Delivery Schedules'
WHERE  function_id = 10161300

UPDATE application_functions
SET    function_name = 'Maintain Delivery Schedule Status',
       function_desc = 'Maintain Delivery Schedule Status'
WHERE  function_id = 10161312
