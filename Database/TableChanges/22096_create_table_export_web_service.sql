IF OBJECT_ID('export_web_service', N'U') IS NULL
BEGIN
	CREATE TABLE export_web_service (
		id INT identity(1,1) PRIMARY KEY,
		ws_name VARCHAR(100),
		ws_description VARCHAR(1000),
		web_service_url VARCHAR(500),
		auth_token VARCHAR(500),
		handler_class_name VARCHAR(100)
	)
END
