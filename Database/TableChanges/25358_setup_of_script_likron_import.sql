/**
 Setup script for Likron import from CLR.
*/
--script 1
IF NOT EXISTS (SELECT 1 FROM ixp_clr_functions where ixp_clr_functions_name = 'Likron')
BEGIN
	INSERT INTO ixp_clr_functions (ixp_clr_functions_name, method_name, description)
	SELECT 'Likron', 'LikronImporter', 'Likron Importer Method'
END 
ELSE 
BEGIN
	UPDATE ixf
	SET ixf.ixp_clr_functions_name = 'Likron'
		, ixf.method_name = 'LikronImporter'
		, ixf.description = 'Likron Importer Method'
	FROM ixp_clr_functions ixf
	WHERE ixp_clr_functions_name = 'Likron'
END


--Script 2
IF NOT EXISTS (
		SELECT 1
		FROM import_web_service iws
		INNER JOIN ixp_clr_functions icf
			ON iws.clr_function_id = icf.ixp_clr_functions_id
		WHERE icf.ixp_clr_functions_name = 'Likron'
		)
BEGIN
	INSERT INTO import_web_service (
		  ws_name
		, web_service_url
		, [user_name]
		, [password]
		, clr_function_id
		)
	SELECT 'Likron'
		, 'https://api-111-test.ffm1.likron.com/TradeList'
		, 'RestApi'
		, dbo.FNAEncrypt('Test0001')
		, icf.ixp_clr_functions_id
	FROM ixp_clr_functions icf
	WHERE icf.ixp_clr_functions_name = 'Likron'
END
ELSE
BEGIN
	UPDATE iws
	SET iws.ws_name = 'Likron'
		, iws.web_service_url = 'https://api-111-test.ffm1.likron.com/TradeList'
		, iws.[user_name] =  'RestApi'
		, iws.[password]  = dbo.FNAEncrypt('Test0001')
	FROM import_web_service iws
	WHERE ws_name = 'RestApi'
END
	

