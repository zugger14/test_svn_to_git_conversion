IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path, book_required)
	VALUES (10183200, 'Maintain Portfolio Group', 'Maintain Portfolio Group', 10180000, 'windowMaintainPortfolioGroup', '_valuation_risk_analysis/maintain_portfolio_group/maintain.portfolio.group.php', 1)
 	PRINT ' Inserted 10183200 - Maintain Portfolio Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183200 - Maintain Portfolio Group already EXISTS.'
END