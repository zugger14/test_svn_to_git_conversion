IF NOT EXISTS(SELECT 'x' FROM dashboardreportname WHERE template_id = 29)
INSERT INTO dashboardreportname(template_id,report_name,instance_name,report_type,module_type)
VALUES (29,'Run Hourly Position Report','windowRunHourlyProductionReport','h',1)