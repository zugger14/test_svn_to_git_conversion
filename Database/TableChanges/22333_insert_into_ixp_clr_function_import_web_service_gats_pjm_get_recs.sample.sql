IF NOT EXISTS (SELECT 1 FROM ixp_clr_functions where ixp_clr_functions_name = 'GatsPjmGetRecs')
BEGIN
	INSERT INTO ixp_clr_functions (ixp_clr_functions_name, method_name, description)
	SELECT 'GatsPjmGetRecs', 'GatsPjmGetRecs', 'Get RECs information from GATS Portal'
END 

IF NOT EXISTS(SELECT 1
				FROM import_web_service iws 
				INNER JOIN ixp_clr_functions icf 
					ON iws.clr_function_id = icf.ixp_clr_functions_id 
				WHERE  icf.ixp_clr_functions_name = 'GatsPjmGetRecs')
BEGIN
	INSERT INTO import_web_service (ws_name, web_service_url,clr_function_id, [user_name], auth_token, request_body, request_params)
	SELECT 'GatsPjmGetRecs', 
			'http://gatsint.pjm-eis.com:8088/Aggregator/Aggregator.asmx',   --TODO Change URL 
			ixp_clr_functions_id,
			'Test1',														--TODO Change Username
			'1FA1074A-A6D4-4522-A77E-D38F73D8798E',							--TODO Change Password
			'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:agg="http://pjm-eis.com/Aggregator">
			   <soapenv:Header/>
			   <soapenv:Body>
				  <agg:GetRECs>
					 <agg:aggName>__user_name__</agg:aggName>
					 <agg:aggToken>__auth_token__</agg:aggToken>
					 <agg:RecSubaccountType></agg:RecSubaccountType>
				  </agg:GetRECs>
			   </soapenv:Body>
			</soapenv:Envelope>',
			'http://pjm-eis.com/Aggregator/GetRECs'
	FROM ixp_clr_functions 
	WHERE ixp_clr_functions_name = 'GatsPjmGetRecs'		
END


