IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102600)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, file_path)
	VALUES (10102600, 'Setup Price Curve', 'Setup Price Curves', 10100000, 'windowSetupPriceCurves', '_setup/setup_price_curves/setup.price.curves.php')

 	PRINT 'Inserted 10102600 - Setup Price Curves.'
END
ELSE
BEGIN
 	UPDATE application_functions SET file_path = '_setup/setup_price_curves/setup.price.curves.php' where function_id = 10102600;

	PRINT 'Updated 10102600 - Setup Price Curves.'
END