If exists(select 1 from application_functions where function_id = 10122500)
BEGIN
	Update application_functions set file_path='_compliance_management/maintain_alerts/maintain.alerts.php' where function_id='10122500'
END
ELSE 
PRINT 'function id 10122500 does not exists.'

If exists(select 1 from application_functions where function_id = 10104100)
BEGIN
	Update application_functions set file_path='_setup/maintain_udf_template/maintain.udf.template.php' where function_id='10104100'
END
ELSE 
PRINT 'function id 10104100 does not exists.'

If exists(select 1 from application_functions where function_id = 10104200)
BEGIN
	Update application_functions set file_path='_setup/maintain_field_template/maintain_field_template.php' where function_id='10104200'
END
ELSE 
PRINT 'function id 10104200 does not exists.'

If exists(select 1 from application_functions where function_id = 10104800)
BEGIN	
	Update application_functions set file_path='_setup/data_import_export/data.import.export.manager.php' where function_id='10104800'
END
ELSE 
PRINT 'function id 10104800 does not exists.'

If exists(select 1 from application_functions where function_id = 10201600)
BEGIN
	Update application_functions set file_path='_reporting/report_manager/report.manager.php' where function_id='10201600'
END
ELSE 
PRINT 'function id 10201600 does not exists.'

If exists(select 1 from application_functions where function_id = 10101400)
BEGIN	
	Update application_functions set file_path='_setup/maintain_deal_template/maintain.deal.template.php' where function_id='10101400'
END
ELSE 
PRINT 'function id 10101400 does not exists.'






