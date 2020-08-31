IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201800)
BEGIN
	UPDATE application_functions SET file_path='_reporting/report_group/report.group.manager.php' WHERE function_id='10201800'
END
ELSE 
PRINT 'function id 10201800 does not exists.'