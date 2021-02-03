DECLARE @report_id INT 
DECLARE @function_id INT
SET @function_id = (select function_id from application_functions where function_name = 'Power BI Reports') 

SELECT @report_id=report_id
FROM report 
WHERE  name = 'Sample Power BI Report 2'

EXEC spa_rfx_report_dhx  @flag='d',@report_id = @report_id, @process_id=NULL	

EXEC spa_application_ui_template 'd', @function_id
	
DELETE FROM application_functional_users WHERE function_id = @function_id
DELETE FROM application_functions WHERE function_id = @function_id