INSERT INTO export_web_service(ws_name,ws_description,web_service_url,auth_token,handler_class_name)
SELECT 'Egssis Gateway','Export report data in json format','https://acceptanceapi.egssis.com/gateway','TESTTOKEN','EgssisEntriesExporter'
