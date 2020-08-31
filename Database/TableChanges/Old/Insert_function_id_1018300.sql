IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10183000)
	PRINT 'Already Exists'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call, file_path)
	VALUES(10183000,'Maintain Monte Carlo Models','Maintain Monte Carlo Models',10180000,'Maintain Monte Carlo Models', '_valuation_risk_analysis/maintain_risk_factor_models/maintain.risk.factor.models.php');
END

--Add/Edit
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10183010)
	PRINT 'Already Exists'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10183010,'Maintain Monte Carlo Models - Add/Edit','Maintain Monte Carlo Models',10180000);
END

-- Delete
IF  EXISTS(SELECT 'X' FROM dbo.application_functions  WHERE function_id = 10183011)
	PRINT 'Already Exists'
ELSE
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES(10183011,'Maintain Monte Carlo Models - Delete','Maintain Monte Carlo Models',10180000);
END

--setup menu
IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 10183000 AND product_category = 10000000)
BEGIN
 	INSERT INTO setup_menu(function_id, display_name, parent_menu_id, window_name, product_category, menu_order, hide_show)
	VALUES (10183000, 'Setup Risk Factor Model', 10180000, 'Maintain Monte Carlo Models', 10000000, 117, 1)
 	PRINT ' Inserted 10183000 - Setup Risk Factor Model.'
END
ELSE
BEGIN
	UPDATE setup_menu
		set display_name = 'Setup Risk Factor Model'
		WHERE function_id = 10183000 AND product_category = 10000000
		
	PRINT 'setup_menu FunctionID 10183000 - Setup Risk Fartor Model already EXISTS.'
END
