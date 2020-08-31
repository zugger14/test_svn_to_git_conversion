IF EXISTS (SELECT 1 FROM ixp_ssis_configurations WHERE package_name = 'weather')
BEGIN
	UPDATE ixp_ssis_configurations
	SET package_description = 'Weather Bank Data Import'
	WHERE package_name = 'weather'
END