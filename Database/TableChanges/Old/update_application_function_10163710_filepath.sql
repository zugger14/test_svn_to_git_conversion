IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163710)
BEGIN
	UPDATE application_functions SET file_path = '_scheduling_delivery/scheduling_workbench/match.php' WHERE function_id = 10163710
	print 'Filepath updated for function ID 10163710.'
END
ELSE
BEGIN
	PRINT 'Application Function Id 10163710 does not EXIST'
END