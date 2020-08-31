IF NOT EXISTS (SELECT 1 FROM ixp_clr_functions where ixp_clr_functions_name = 'PowerfactorMntlyVols')
BEGIN
	INSERT INTO ixp_clr_functions (ixp_clr_functions_name, method_name, description)
	SELECT 'PowerfactorMntlyVols', 'PowerfactorMntlyVolsImporter', 'Import Monthly Volumes from PowerFactor'
END 

IF NOT EXISTS(SELECT 1
				FROM import_web_service iws 
				INNER JOIN ixp_clr_functions icf 
					ON iws.clr_function_id = icf.ixp_clr_functions_id 
				WHERE  icf.ixp_clr_functions_name = 'PowerfactorMntlyVols')
BEGIN
	INSERT INTO import_web_service (ws_name, web_service_url, clr_function_id, auth_token, request_body)
	SELECT 'PowerfactorMntlyVols', 
			'https://api.powerfactorscorp.com/drive/v2/data', 
			ixp_clr_functions_id,
			'c18b1bff88bf4715b6e4cba84495a9b3',
			'{
				  "startTime": "<__start_time__>",
				  "endTime": "<__end_time__>",
				  "resolution": "day",
				  "attributes": [
					"ENERGY_BILLABLE"
				  ],
				  "ids": [
					"<__id__>"
				  ]
			}'
	FROM ixp_clr_functions 
	WHERE ixp_clr_functions_name = 'PowerfactorMntlyVols'		
END
