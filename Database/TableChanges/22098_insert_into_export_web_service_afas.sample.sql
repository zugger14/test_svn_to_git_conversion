IF NOT EXISTS (SELECT 1 FROM export_web_service WHERE handler_class_name = 'AFASFIEntriesExporter') 
BEGIN
	INSERT INTO export_web_service (ws_name, ws_description, web_service_url, auth_token, handler_class_name)
	SELECT 
	'AFAS Interface'
	, 'Post GL Entires to Greenchoice AFAS Online Web Service'
	, 'https://45584.afasonlineconnector.nl/profitrestservices/connectors/FiEntries'
	, 'PHRva2VuPjx2ZXJzaW9uPjE8L3ZlcnNpb24+PGRhdGE+OTY5RjgwMThCQzc2NEQ1RDhBMkYyRkY0MzMyOEI4NUUyNEVCQkJFQjRGODNFNjQ4MjU0RDk5RDBEQzcxN0VFMzwvZGF0YT48L3Rva2VuPg=='
	, 'AFASFIEntriesExporter'
END 
