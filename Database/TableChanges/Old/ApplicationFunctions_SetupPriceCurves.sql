/*Added by Poojan Shrestha, 15 Feb 2011*/
IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102600)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102600,'Setup Price Curves','Setup Price Curves',10100000,'windowSetupPriceCurves')
	PRINT '10102600 INSERTED'
END

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102610)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102610,'Setup Price Curves IU','Setup Price Curves IU',10102600,'windowSetupPriceCurvesIU')
	PRINT '10102610 INSERTED'
END