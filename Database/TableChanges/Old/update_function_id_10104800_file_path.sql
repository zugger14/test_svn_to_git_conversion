IF EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10104800)
BEGIN
UPDATE application_functions
SET file_path = '_setup/data_import_export/data.import.export.php'
WHERE function_id = 10104800
END
