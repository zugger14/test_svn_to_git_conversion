IF NOT EXISTS (SELECT * FROM application_functions WHERE function_id = 10231000)
BEGIN
	INSERT INTO application_functions 
	(
		function_id,
		function_name,
		function_desc,
		func_ref_id,
		function_call,
		file_path,
		book_required
	)
	VALUES
	(
		10231000,
		'Setup Inventory GL Account',
		'Setup Inventory GL Account',
		10100000,
		'windowSetupInventoryGLAccount',
		'_accounting/inventory/maintain.inventory.gl.account/maintain.inventory.gl.account.php',
		0
	)

	PRINT 'Setup Inventory GL Account inserted.'
END
ELSE
BEGIN
	PRINT 'Setup Inventory GL Account already exist.'
END