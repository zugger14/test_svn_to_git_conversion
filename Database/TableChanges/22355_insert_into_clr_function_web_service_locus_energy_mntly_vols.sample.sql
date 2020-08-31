IF NOT EXISTS (SELECT 1 FROM ixp_clr_functions where ixp_clr_functions_name = 'LocusEnergyMntlyVols')
BEGIN
	INSERT INTO ixp_clr_functions (ixp_clr_functions_name, method_name, description)
	SELECT 'LocusEnergyMntlyVols', 'LocusEnergyMntlyVolsImporter', 'Get Monlthy Volumes from Locus Energy'
END 

IF NOT EXISTS(SELECT 1
				FROM import_web_service iws 
				INNER JOIN ixp_clr_functions icf 
					ON iws.clr_function_id = icf.ixp_clr_functions_id 
				WHERE  icf.ixp_clr_functions_name = 'LocusEnergyMntlyVols')
BEGIN
	INSERT INTO import_web_service (ws_name, web_service_url, clr_function_id, [user_name], [password], auth_url, client_id, client_secret)
	SELECT 'LocusEnergyMntlyVols', 
			'https://api.locusenergy.com/v3/sites/<__site_id__>/data', 
			ixp_clr_functions_id,
			'pioneer@terraform.com',
			dbo.FNAEncrypt('Welcome123'),
			'https://api.locusenergy.com/oauth/token',
			'f5a68a173242c549c416d6aa8dd496fe',
			'1c0d5005143bf75484feb799d5a28f71'
	FROM ixp_clr_functions 
	WHERE ixp_clr_functions_name = 'LocusEnergyMntlyVols'		
END


