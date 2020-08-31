IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10164400)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10164400, 'View Edit Nomination', 'View Edit Nomination', 10160000, 'windowViewEditNom', '_scheduling_delivery/View Edit Nomination/view.edit.nom.php')
 	PRINT ' Inserted 10164400 - View Edit Nomination.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10164400 - View Edit Nomination already EXISTS.'
END
