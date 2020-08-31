
IF NOT EXISTS(SELECT 1 FROM application_functions where  function_id=20001100 AND file_path= '_setup/import_data_interface/import.data.interface.php')
BEGIN
UPDATE application_functions SET file_path = '_setup/import_data_interface/import.data.interface.php'
 where function_id=20001100
END