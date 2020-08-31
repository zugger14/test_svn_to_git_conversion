
/**************************************************
* Creted By : Tara Nath Subedi
* Created Date:30-Jun-2010
* purpose: dashboard report added for Compliance Due Date Violation
***************************************************/

IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 13) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(13,'Compliance Due Date Violation Report','RunComplianceDateVoilationReport','p')
END 