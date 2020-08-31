IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162300)
BEGIN
UPDATE application_functions
SET file_path = '_scheduling_delivery/gas/virtual_storage/virtual.storage.php'
WHERE function_id = 10162300
END