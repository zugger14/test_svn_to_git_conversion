DELETE bpn 
FROM batch_process_notifications bpn
INNER JOIN (
	SELECT id,handler_class_name, 
     row_number() OVER(PARTITION BY handler_class_name ORDER BY id) AS [rn]
	FROM export_web_service
) tbl
	ON tbl.id = bpn.export_web_services_id
WHERE tbl.rn > 1

DELETE rsrl 
FROM remote_service_response_log rsrl
INNER JOIN (
	SELECT id,handler_class_name, 
     row_number() OVER(PARTITION BY handler_class_name ORDER BY id) AS [rn]
	FROM export_web_service
) tbl
	ON tbl.id = rsrl.export_web_service_id
WHERE tbl.rn > 1


DELETE ews
FROM export_web_service ews
INNER JOIN (
	SELECT id,handler_class_name, 
     row_number() OVER(PARTITION BY handler_class_name ORDER BY id) AS [rn]
	FROM export_web_service
) tbl
	ON tbl.id = ews.id
WHERE tbl.rn > 1

IF NOT EXISTS ( SELECT 1
FROM export_web_service
WHERE handler_class_name = 'EgssisEntriesExporter'
)
BEGIN
	INSERT INTO export_web_service(ws_name,ws_description,web_service_url,auth_token,handler_class_name)
	SELECT 'Egssis Gateway','Export report data in json format','https://acceptanceapi.egssis.com/gateway','TESTTOKEN','EgssisEntriesExporter'
END
ELSE
BEGIN
	UPDATE export_web_service
	SET ws_name = 'Egssis Gateway',
	    ws_description = 'Export report data in json format',
		web_service_url = 'https://acceptanceapi.egssis.com/gateway',
		auth_token = 'TESTTOKEN'
	WHERE handler_class_name = 'EgssisEntriesExporter'
END
