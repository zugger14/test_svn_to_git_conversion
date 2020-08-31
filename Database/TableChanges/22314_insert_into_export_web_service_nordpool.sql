IF NOT EXISTS ( SELECT 1
FROM export_web_service
WHERE handler_class_name = 'NordpoolExporter'
)
BEGIN
	INSERT INTO export_web_service(ws_name,ws_description,web_service_url,auth_token,handler_class_name)
	SELECT 'Nordpool Gateway','Export report data in xml format','https://apiremit.test.nordpoolgroup.com/','TESTTOKEN','NordpoolExporter'
END
ELSE
BEGIN
	UPDATE export_web_service
	SET ws_name = 'Nordpool Gateway',
	    ws_description = 'Export report data in xml format',
		web_service_url = 'https://apiremit.test.nordpoolgroup.com/',
		auth_token = 'TESTTOKEN'
	WHERE handler_class_name = 'NordpoolExporter'
END
