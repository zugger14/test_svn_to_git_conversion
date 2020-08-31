IF NOT EXISTS ( SELECT 1
FROM export_web_service
WHERE handler_class_name = 'RegisTrExporter'
)
BEGIN
	INSERT INTO export_web_service(ws_name,ws_description,web_service_url,auth_token,handler_class_name)
	SELECT 'RegisTR Gateway','Export report data in xml format','https://pre-productionws.regis-tr.com/soapapi.svc/mex?wsdl','TESTTOKEN','RegisTrExporter'
END
ELSE
BEGIN
	UPDATE export_web_service
	SET ws_name = 'RegisTR Gateway',
	    ws_description = 'Export report data in xml format',
		web_service_url = 'https://pre-productionws.regis-tr.com/soapapi.svc/mex?wsdl',
		auth_token = 'TESTTOKEN'
	WHERE handler_class_name = 'RegisTrExporter'
END
