IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131800, 'Transfer Term Position', 'Transfer Term Position', 10130000, 'windowTransferTermPosition')
 	PRINT ' Inserted 10131800 - Transfer Term Position.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131800 - Transfer Term Position already EXISTS.'
END

UPDATE application_functions
SET    file_path       = 
       '_deal_capture/transfer_term_position/transfer.term.position.php'
WHERE  function_id     = 10131800
