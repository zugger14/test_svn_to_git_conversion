IF NOT EXISTS (SELECT 1 FROM export_web_service WHERE handler_class_name = 'NepoolTransferRequestExporter') 
BEGIN
	INSERT INTO export_web_service (ws_name, ws_description, web_service_url, handler_class_name, [user_name], auth_url, [password])
	SELECT 
	'Nepool Transfer RECs'
	, 'Export RECs to Nepool webservice using JSON format'
	, 'https://gis-app-uat01.apx.com/clientapi2/api/'				--TODO: Change URL
	, 'NepoolTransferRequestExporter'
	, 'trmapi'														--TODO: Change Username
	, 'https://apxjwtauthuat.apx.com/oauth/token'					--TODO: Change Authenticate URL
	, dbo.FNAEncrypt('TRMTracker@2020')								--TODO: Change Password
END 

/* 
TODO:
SELECT * FROM static_data_value WHERE type_id = 10011 AND code= 'Nepool' 
SELECT * FROM static_data_type WHERE type_id = 10011 
Type Id 10011 (Certification Systems) is external type
Update value of certificate_entity with value_id(static_data_value) of Code = 'Nepool'  with type_id 10011
*/

UPDATE export_web_service 
SET ws_name = 'Nepool Transfer RECs',
certificate_entity = 50003082									--TODO Change value					
WHERE handler_class_name = 'NepoolTransferRequestExporter'