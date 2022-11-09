UPDATE import_web_service SET
ws_name = 'EpexRetrieveMarketResultsForDayAhead'
WHERE ws_name = 'EPEXRetrieveMarketResultsForDayAhead'

UPDATE ixp_clr_functions
SET ixp_clr_functions_name = 'EpexRetrieveMarketResultsForDayAhead', method_name = 'EpexRetrieveMarketResultsForImporter'
WHERE ixp_clr_functions_name = 'EPEXRetrieveMarketResultsForDayAhead'

IF NOT EXISTS (SELECT 1 FROM ixp_clr_functions WHERE ixp_clr_functions_name = 'EpexRetrieveMarketResultsForDayAhead')
BEGIN
	INSERT INTO ixp_clr_functions (ixp_clr_functions_name, method_name, description)
	SELECT 'EpexRetrieveMarketResultsForDayAhead', 'EpexRetrieveMarketResultsForDayAheadImporter', 'Import Curve data from EPEX'
END 
DECLARE @ixp_clr_functions_id INT

SELECT @ixp_clr_functions_id = ixp_clr_functions_id 
FROM ixp_clr_functions 
WHERE method_name  = 'EpexRetrieveMarketResultsForDayAheadImporter'

IF (@ixp_clr_functions_id IS NOT NULL) 
BEGIN
	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_AuctionArea' AND clr_function_id = @ixp_clr_functions_id)
	BEGIN
		INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, sql_string)
		SELECT 'PS_AuctionArea','Auction Area', 1, 'combo', @ixp_clr_functions_id , 'Required Field', 'y', 'EXEC spa_StaticDataValues ''h'', 112500'
	END

	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_AuctionDate' AND clr_function_id = @ixp_clr_functions_id)
	BEGIN
		INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_format)
		SELECT 'PS_AuctionDate','Auction Date', 1, 'calendar', @ixp_clr_functions_id , 'Required Field', 'y', 't'
	END
	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_AuctionName' AND clr_function_id = @ixp_clr_functions_id)
	BEGIN
		INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, sql_string)
		SELECT 'PS_AuctionName','Auction Name', 1, 'combo', @ixp_clr_functions_id , 'Required Field', 'y', 'EXEC spa_StaticDataValues ''h'', 112600'
	END
END

IF NOT EXISTS(SELECT 1
				FROM import_web_service iws 
				INNER JOIN ixp_clr_functions icf 
					ON iws.clr_function_id = icf.ixp_clr_functions_id 
				WHERE  icf.ixp_clr_functions_name = 'EpexRetrieveMarketResultsForDayAhead')
BEGIN
	INSERT INTO import_web_service (ws_name, web_service_url, clr_function_id, [user_name], [password], client_secret, request_body, password_updated_date, auth_token)
	SELECT 'EpexRetrieveMarketResultsForDayAhead', 
			'https://api-ets2.epex.simu.epexspot.com/OpenAccess/3.6',  --TODO Change values according to enviroment 
			ixp_clr_functions_id,
			'TSWHNBCDAPI50',										--TODO Change values according to enviroment
			dbo.FNAEncrypt('TSWHNBC03November2022!'),						--TODO Change values according to enviroment
			'TRM2020',
			'<?xml version="1.0" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:openaccess">
   <soapenv:Header>
      <urn:ResponseLimitationHeader>
        </urn:ResponseLimitationHeader>
      <urn:SessionToken>
         <urn:userLoginName><__user_name__></urn:userLoginName>
         <urn:sessionKey><__auth_token__></urn:sessionKey></urn:SessionToken>
      <urn:AsynchronousResponseHeader>
         <urn:asynchronousResponse>1</urn:asynchronousResponse>
        <urn:responseToken>1</urn:responseToken>
      </urn:AsynchronousResponseHeader>
   </soapenv:Header>
   <soapenv:Body>
      <urn:RetrieveMarketResultsFor>
         <MarketResultIdentifier>
            <urn:area><__auction_area__></urn:area>
            <urn:auctionIdentification>
                <urn:AuctionDate><__auction_date__></urn:AuctionDate>
               <urn:name><__auction_name__></urn:name>
              </urn:auctionIdentification>
         </MarketResultIdentifier>
      </urn:RetrieveMarketResultsFor>
   </soapenv:Body>
</soapenv:Envelope>',
 '2022-11-02',--TODO Change values according to enviroment
 '36660175660574339149359231156058441412054325707580475916457027002352104567621841'
	FROM ixp_clr_functions 
	WHERE ixp_clr_functions_name = 'EpexRetrieveMarketResultsForDayAhead'		
END

UPDATE import_web_service SET
web_service_url ='https://api-ets2.epex.simu.epexspot.com/OpenAccess/3.6'
--, certificate_path = 'F:\FARRMS_SPTFiles\CLR\TRMTracker_Enercity_UAT\EPEX\Certificate\ETS_Cert_simu.pfx' --TODO Change values according to enviroment
WHERE ws_name = 'EpexRetrieveMarketResultsForDayAhead'
