IF NOT EXISTS (SELECT 1 FROM ixp_clr_functions where ixp_clr_functions_name = 'NepoolTransferablePositions')
BEGIN
	INSERT INTO ixp_clr_functions (ixp_clr_functions_name, method_name, [description])
	SELECT 'NepoolTransferablePositions', 'NepoolTransferablePosImporter', 'Get Transferable Positions from NEPOOL'
END 

IF NOT EXISTS(SELECT 1
				FROM import_web_service iws 
				INNER JOIN ixp_clr_functions icf 
					ON iws.clr_function_id = icf.ixp_clr_functions_id 
				WHERE  icf.ixp_clr_functions_name = 'NepoolTransferablePositions')
BEGIN
	INSERT INTO import_web_service (ws_name, web_service_url, clr_function_id, [user_name], [password], auth_url)
	SELECT 'NepoolTransferablePositions', 
			'https://gis-app-uat01.apx.com/clientapi2/api/',    --TODO: Change URL Value
			ixp_clr_functions_id,
			'trmapi',											--TODO: Change Username Value
			dbo.FNAEncrypt('TRMTracker@2020'),					--TODO: Change Password Value
			'https://apxjwtauthuat.apx.com/oauth/token'			--TODO: Change Authenticate URL Value
	FROM ixp_clr_functions 
	WHERE ixp_clr_functions_name = 'NepoolTransferablePositions'		
END