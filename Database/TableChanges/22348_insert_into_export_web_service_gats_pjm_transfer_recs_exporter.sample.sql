IF NOT EXISTS (SELECT 1 FROM export_web_service WHERE handler_class_name = 'GatsPjmTransferRecsExporter') 
BEGIN
	INSERT INTO export_web_service (ws_name, ws_description, web_service_url, auth_token, handler_class_name, [user_name], request_param)
	SELECT 
	'GATS PJM Transfer RECs'
	, 'Export RECs to GATS webservice'
	, 'http://gatsint.pjm-eis.com:8088/Aggregator/Aggregator.asmx'  --TODO: Change URL
	, '1FA1074A-A6D4-4522-A77E-D38F73D8798E'						--TODO: Change Token
	, 'GatsPjmTransferRecsExporter'
	, 'Test1'														--TODO: Change User name
	, 'http://pjm-eis.com/Aggregator/TransferRec'
END 

/* 
TODO:
SELECT * FROM static_data_value WHERE type_id = 10011 AND code= 'PJM' -- (PJM GATS)
SELECT * FROM static_data_type WHERE type_id = 10011 
Type Id 10011 (Certification Systems) is external type
Update value of certificate_entity with value_id(static_data_value) of Code = 'PJM' (PJM GATS) with type_id 10011
*/

UPDATE export_web_service 
SET ws_name = 'GATS PJM Transfer RECs',
certificate_entity = 50002668									--TODO Change value					
WHERE handler_class_name = 'GatsPjmTransferRecsExporter'
