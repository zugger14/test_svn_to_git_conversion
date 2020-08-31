/*  
* Code to update setup_menu
*/
UPDATE setup_menu
SET    window_name = 'WindowRunDashReport',
       display_name = 'Run Dashboard Report',
       hide_show = 0
WHERE  function_id = 10201100
       AND product_category = 10000000 

UPDATE setup_menu
SET    window_name = 'WindowDashReportTemplate',
       display_name = 'Dashboard Report Template',
       hide_show = 0
WHERE  function_id = 10201200
       AND product_category = 10000000        
       


