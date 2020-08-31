/*
Insert query to added web info with clr function.
*/

IF NOT EXISTS(SELECT 1
				FROM import_web_service iws 
				INNER JOIN ixp_clr_functions icf 
					ON iws.clr_function_id = icf.ixp_clr_functions_id 
				WHERE  icf.ixp_clr_functions_name = 'NymexTreasuryPlattsPriceCurve')
BEGIN
	INSERT INTO import_web_service (ws_name, web_service_url,clr_function_id)
	SELECT 'NymexTreasuryPlattsPriceCurve', 
			'http://www.treasury.gov/resource-center/data-chart-center/interest-rates/Datasets/yield.xml', 
			ixp_clr_functions_id
	FROM ixp_clr_functions 
	WHERE ixp_clr_functions_name = 'NymexTreasuryPlattsPriceCurve'		
END