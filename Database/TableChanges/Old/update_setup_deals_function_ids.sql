IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131000)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131000, 'Create and View Deals', 'Create and View Deals', 10130000, '_deal_capture/maintain_deals/maintain.deals.php')
 	PRINT ' Inserted 10131000 - Create and View Deals.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131000 - Create and View Deals already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131010, 'Add/Save', 'Add/Save', 10131000, NULL)
 	PRINT ' Inserted 10131010 - Add/Save.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Add/Save',
		function_desc = 'Add/Save',
		function_call = NULL,
		func_ref_id = 10131000
	WHERE function_id = 10131010
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131011)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131011, 'Delete', 'Delete', 10131000, NULL)
 	PRINT ' Inserted 10131011 - Delete.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Delete',
		function_desc = 'Delete',
		function_call = NULL,
		func_ref_id = 10131000
	WHERE function_id = 10131011
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131012)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131012, 'Change Deal Status', 'Change Deal Status', 10131000, NULL)
 	PRINT ' Inserted 10131012 - Change Deal Status.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Change Deal Status',
		function_desc = 'Change Deal Status',
		function_call = NULL,
		func_ref_id = 10131000
	WHERE function_id = 10131012
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131013)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131013, 'Change Confirm Status', 'Change Confirm Status', 10131000, NULL)
 	PRINT ' Inserted 10131013 - Change Confirm Status.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Change Confirm Status',
		function_desc = 'Change Confirm Status',
		function_call = NULL,
		func_ref_id = 10131000
	WHERE function_id = 10131013
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131014)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131014, 'Lock Deals', 'Lock Deals', 10131000, NULL)
 	PRINT ' Inserted 10131014 - Lock Deals.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Lock Deals',
		function_desc = 'Lock Deals',
		function_call = NULL,
		func_ref_id = 10131000
	WHERE function_id = 10131014
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131015)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131015, 'Unlock Deals', 'Unlock Deals', 10131000, NULL)
 	PRINT ' Inserted 10131015 - Unlock Deals.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Unlock Deals',
		function_desc = 'Unlock Deals',
		function_call = NULL,
		func_ref_id = 10131000
	WHERE function_id = 10131015
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131016)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131016, 'View Audit Report', 'View Audit Report', 10131000, NULL)
 	PRINT ' Inserted 10131015 - View Audit Report.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'View Audit Report',
		function_desc = 'View Audit Report',
		function_call = NULL,
		func_ref_id = 10131000
	WHERE function_id = 10131016
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131017)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131017, 'Deal Document', 'Deal Document', 10131000, NULL)
 	PRINT ' Inserted 10131017 - Deal Document.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Deal Document',
		function_desc = 'Deal Document',
		function_call = NULL,
		func_ref_id = 10131000
	WHERE function_id = 10131017
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131018)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, file_path)
	VALUES (10131018, 'Update Volume', 'Update Volume', 10131000, NULL)
 	PRINT ' Inserted 10131017 - Update Volume.'
END
ELSE
BEGIN
	UPDATE application_functions
	SET function_name = 'Update Volume',
		function_desc = 'Update Volume',
		function_call = NULL,
		func_ref_id = 10131000
	WHERE function_id = 10131018
END