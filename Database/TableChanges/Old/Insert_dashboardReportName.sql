
/**************************************************
* Creted By : Pavan Khanal
* Created Date:14-Jan-2010
* purpose: Report add for TRMTracker_EMS
***************************************************/

IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 1) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(1,'Tracking Report','windowRunGHGTrackingReport','h')
END 