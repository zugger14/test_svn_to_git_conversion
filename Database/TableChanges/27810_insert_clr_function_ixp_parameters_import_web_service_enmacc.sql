/**
 Add CLR function
*/
IF NOT EXISTS (SELECT 1 FROM ixp_clr_functions where ixp_clr_functions_name = 'ENMACC')
BEGIN
	INSERT INTO ixp_clr_functions (ixp_clr_functions_name, method_name, description)
	SELECT 'ENMACC', 'ENMACCImporter', 'ENMACC Trader Importer Method'
END 
ELSE 
BEGIN
	UPDATE ixf
	SET ixf.ixp_clr_functions_name = 'ENMACC'
		, ixf.method_name = 'ENMACCImporter'
		, ixf.description = 'ENMACC Trade Importer Method'
	FROM ixp_clr_functions ixf
	WHERE ixp_clr_functions_name = 'ENMACC'
END

/**
 Add import web services
*/
IF NOT EXISTS (
		SELECT *
		FROM import_web_service iws
		INNER JOIN ixp_clr_functions icf
			ON iws.clr_function_id = icf.ixp_clr_functions_id
		WHERE icf.ixp_clr_functions_name = 'ENMACC'
		)
BEGIN
	INSERT INTO import_web_service (
		  ws_name
		, web_service_url
		, request_body
		, auth_url
		, client_id
		, client_secret
		, clr_function_id
		, api_key
		)
	SELECT 'ENMACC'
		, 'https://connect-sandbox.enmacc.com/v2.0' -- TO Update API URL
		, '{"grant_type": "client_credentials", "client_id": "<__client_id__>", "client_secret": "<__client_secret__>" }'
		, 'https://connect-sandbox.enmacc.com/v2.1/authenticate'  -- TO Update API auth URL
		, 'NoYhBg9bFY9u'
		, 'HJ9m2LokMRQc'
 	    , icf.ixp_clr_functions_id
		,'rCCCb70xcp2fnh1mQslKa9ktVxEtALNBsCvs8Bn7'
	FROM ixp_clr_functions icf
	WHERE icf.ixp_clr_functions_name = 'ENMACC'
END
ELSE
BEGIN
	UPDATE iws
	SET  iws.web_service_url =  'https://connect-sandbox.enmacc.com/v2.0' --TO DO UPdate API URL
		, iws.request_body = '{"grant_type": "client_credentials", "client_id": "<__client_id__>", "client_secret": "<__client_secret__>" }'
		, iws.auth_url= 'https://connect-sandbox.enmacc.com/v2.1/authenticate' -- TO Update API auth URL
		, iws.client_id =  'NoYhBg9bFY9u'
		, iws.client_secret = 'HJ9m2LokMRQc' --TO DO Update API PW
		, iws.api_key = 'rCCCb70xcp2fnh1mQslKa9ktVxEtALNBsCvs8Bn7'
		FROM import_web_service iws
	WHERE ws_name = 'ENMACC'
END

/**
 Add ixp parameters
*/
DECLARE @ixp_clr_functions_id INT

SELECT @ixp_clr_functions_id = ixp_clr_functions_id 
FROM ixp_clr_functions 
WHERE method_name  = 'ENMACCImporter'

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_Commodity' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value, sql_string, default_format)
	SELECT 'PS_Commodity' --parameter_name
	, 'Commodity' -- parameter_label
	, 1	 -- operator_id
	, 'combo' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'n' -- insert_required
	, NULL -- default_value
	,'SELECT ''gas'' as value, ''gas'' as name UNION SELECT ''power'' as value, ''power'' as name UNION SELECT ''guarantee-of-origin'' as value, ''guarantee-of-origin'' as name UNION SELECT ''el-certificate'' as value, ''el-certificate'' as name'
	, NULL --default format
END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_Venue' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value, sql_string, default_format)
	SELECT 'PS_Venue' --parameter_name
	, 'Venue' -- parameter_label
	, 1	 -- operator_id
	, 'combo' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'n' -- insert_required
	, NULL -- default_value
	, 'SELECT ''entender'' as value, ''entender'' as name UNION SELECT ''enmarket'' as value, ''enmarket'' as name UNION SELECT ''engreen'' as value, ''engreen'' as name'
	, NULL  --default format
END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_TradedStart' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value, default_format)
	SELECT 'PS_TradedStart' --parameter_name
	, 'Traded Start Date' -- parameter_label
	, 1	 -- operator_id
	, 'calendar' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, 'Required Field' --validation_message
	, 'y' -- insert_required
	, NULL -- default_value
	,'t' -- default format

END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_TradedEnd' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value, default_format)
	SELECT 'PS_TradedEnd' --parameter_name
	, 'Traded End Date' -- parameter_label
	, 1	 -- operator_id
	, 'calendar' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, 'Required Field' --validation_message
	, 'y' -- insert_required
	, NULL -- default_value
	,'t' -- default format
END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_Skip' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_Skip' --parameter_name
	, 'Skip' -- parameter_label
	, 1	 -- operator_id
	, 'input' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'n' -- insert_required
	, NULL -- default_value

END


IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_Limit' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_Limit' --parameter_name
	, 'Limit' -- parameter_label
	, 1	 -- operator_id
	, 'input' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'n' -- insert_required
	, 50 -- default_value
	
END


	
