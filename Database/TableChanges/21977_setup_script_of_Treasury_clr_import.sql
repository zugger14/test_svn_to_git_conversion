--CLR import setup script.

--Setup 1: Insert script for CLR method.
IF NOT EXISTS (
		SELECT 1
		FROM ixp_clr_functions
		WHERE ixp_clr_functions_name = 'Treasury'
		)
BEGIN
	INSERT INTO ixp_clr_functions (
		ixp_clr_functions_name
		, method_name
		, description
		)
	SELECT 'Treasury'
		, 'TreasuryImporter'
		, 'Treasury Importer Method'
END
ELSE
	UPDATE ixf
	SET ixf.ixp_clr_functions_name = 'Treasury'
		, ixf.method_name = 'TreasuryImporter'
		, ixf.description = 'Treasury Importer Method'
	--SELECT * 
	FROM ixp_clr_functions ixf
	WHERE ixp_clr_functions_name = 'Treasury'

	select * from import_web_service

--Setup 2: Insert script to define url
IF NOT EXISTS (
		SELECT 1
		FROM import_web_service iws
		INNER JOIN ixp_clr_functions icf
			ON iws.clr_function_id = icf.ixp_clr_functions_id
		WHERE icf.ixp_clr_functions_name = 'Treasury'
		)
BEGIN
	INSERT INTO import_web_service (
		  ws_name
		, web_service_url
		, clr_function_id
		)
	SELECT 'Treasury'
		, 'http://www.treasury.gov/resource-center/data-chart-center/interest-rates/Datasets/yield.xml'
		, ixp_clr_functions_id
	FROM ixp_clr_functions
	WHERE ixp_clr_functions_name = 'Treasury'
END
ELSE
	UPDATE iws
	SET iws.ws_name = 'Treasury'
		, iws.web_service_url = 'http://www.treasury.gov/resource-center/data-chart-center/interest-rates/Datasets/yield.xml'
		, iws.clr_function_id = icf.ixp_clr_functions_id
	FROM import_web_service iws
	INNER JOIN ixp_clr_functions icf
		ON iws.clr_function_id = icf.ixp_clr_functions_id
	WHERE icf.ixp_clr_functions_name = 'Treasury'


/*
SELECT *
FROM ixp_clr_functions

SELECT * FROM import_web_service
*/