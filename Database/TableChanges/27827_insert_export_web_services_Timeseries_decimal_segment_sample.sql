/* insert/update script after new column (auth_key) is added to insert contractGUID in auth_key instead of auth_token */

DECLARE @web_service_url varchar(500) =   'https://demo.ez-operations.com/enercitydev/rest/1.0/tokens' --TODO Change 
 , @ContractGUID varchar(500) = 'EZ3ee6917c6a' --TODO Change 
 , @user_name varchar(50)= 'enercityapi'  --TODO change 
 , @password varbinary(100) =  dbo.FNAENCRYPT('enercityapi_demo') --TODO change 

IF NOT EXISTS (SELECT 1 FROM export_web_service WHERE handler_class_name = 'EznergyTDSExporter') 
BEGIN
	INSERT INTO export_web_service (
	  ws_name
	, ws_description
	, handler_class_name
	, web_service_url
	, auth_key
	, [user_name]
	, [password])
	SELECT 
	  'Timeseries Decimal Segments'
	, 'Timeseries Decimal Segments'
	, 'EznergyTDSExporter'
	, @web_service_url
	, @ContractGUID
	, @user_name
	, @password
END 
ELSE 
BEGIN 
	UPDATE ews
		SET   ews.web_service_url = @web_service_url
			, ews.auth_key  = @ContractGUID
			, ews.[user_name] =  @user_name
			, ews.[password] =  @password
	FROM export_web_service ews WHERE ews.handler_class_name = 'EznergyTDSExporter'
END
