-- Script to insert Application Function Id :
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10131300, 'Import Data', 'Import Data', 10130000, 'windowImportDataDeal', '_accounting/derivative/deal_capture/import_data/import.data.php?call_from=d')

 	PRINT 'Inserted 10131300 - Import Data.'
END
ELSE
BEGIN
 	UPDATE application_functions SET file_path = '_accounting/derivative/deal_capture/import_data/import.data.php?call_from=d' where function_id = 10131300;

	PRINT 'Updated 10131300 - Import Data.'
END