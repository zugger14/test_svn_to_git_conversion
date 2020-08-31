IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234000, 'Reclassify Hedge De-Designation', 'Reclassify Hedge De-Designation', 10230000, 'windowReclassifyDedesignationValues')
 	PRINT ' Inserted 10234000 - Reclassify Hedge De-Designation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234000 - Reclassify Hedge De-Designation already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234010, 'Delete Reclassify Hedge De-Designation', 'Delete Reclassify Hedge De-Designation', 10234000, NULL)
 	PRINT ' Inserted 10234010 - Delete Reclassify Hedge De-Designation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234010 - Delete Reclassify Hedge De-Designation already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234011)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234011, 'Reclassify Date', 'Reclassify Date', 10234000, 'windowReclassifyDateIU')
 	PRINT ' Inserted 10234011 - Reclassify Date.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234011 - Reclassify Date already EXISTS.'
END
