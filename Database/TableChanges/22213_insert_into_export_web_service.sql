IF NOT EXISTS ( SELECT 1
FROM export_web_service
WHERE handler_class_name = 'EgssisCapacityBooking'
)
BEGIN
	INSERT INTO export_web_service(ws_name,ws_description,web_service_url,auth_token,handler_class_name)
	SELECT 'Capacity Booking','Export report data in json format','https://acceptanceapi.egssis.com/gateway','TESTTOKEN','EgssisCapacityBooking'
END
ELSE
BEGIN
	UPDATE export_web_service
	SET ws_name = 'Egssis Capacity Booking',
	    ws_description = 'Export report data in json format',
		web_service_url = 'https://acceptanceapi.egssis.com/gateway',
		auth_token = 'TESTTOKEN'
	WHERE handler_class_name = 'EgssisCapacityBooking'
END
