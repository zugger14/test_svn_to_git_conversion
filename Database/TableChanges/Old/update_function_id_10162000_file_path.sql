IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162000)
BEGIN
UPDATE application_functions
SET file_path = '_scheduling_delivery/gas/maintain_transportation_rate_schedule/maintain_transportation_rate_schedule_main.php'
WHERE function_id = 10162000
END
--SELECT * FROM application_functions WHERE function_id = 10162000