--CounterpartyCreditInfo
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10101122)
	PRINT 'Counterparty Credit Information already exists'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,file_path)
	VALUES(10101122,'Counterparty Credit Information','Counterparty Credit Information',10190000, '_credit_risks_analysis/counterparty_credit_info/counterparty.credit.info.php');
END

--setup menu
IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10101122 AND product_category = 10000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show)
	VALUES (10101122, 'Counterparty Credit Information', 10190000, 'Counterparty Credit Information', 10000000, 117, 1)
 	PRINT ' Inserted 10101122 - Counterparty Credit Information.'
END
ELSE
BEGIN
	UPDATE setup_menu SET display_name = 'Counterparty Credit Information'
	WHERE function_id = 10101122 
	AND product_category = 10000000

	PRINT 'setup_menu FunctionID 10101122 - Counterparty Credit Information.'
END

--Add/Edit
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10101123)
	PRINT 'Already Exists'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101123,'Add/Edit','Counterparty Credit Information - Add/Edit',10190000);
END

-- Delete
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10101124)
	PRINT 'Already Exists'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101124,'Delete','Counterparty Credit Information - Delete',10190000);
END

--CounterpartyCreditInfo Limit
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10181313)
	PRINT 'Counterparty Credit Information - Limit already exists'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10181313,'Counterparty Credit Information - Limit','Counterparty Credit Information - Limit',10180000);
END

--CounterpartyCreditInfo Enhancements
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10101125)
	PRINT 'Counterparty Credit Information - Enhancements already exists'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10101125,'Counterparty Credit Information - Enhancements','Counterparty Credit Information - Enhancements',10180000);
END