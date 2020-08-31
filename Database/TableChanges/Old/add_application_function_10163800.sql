IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10163800)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call,file_path)
	VALUES (10163800, 'Split Nom Volume', 'Split Nom Volume', 10160000, 'windowSplitNomVolume','_scheduling_delivery/gas/split_nom_volume/split.nom.volume.php')
 	PRINT ' Inserted 10163800 - Split Nom Volume.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10163800 - Split Nom Volume already EXISTS.'
END


