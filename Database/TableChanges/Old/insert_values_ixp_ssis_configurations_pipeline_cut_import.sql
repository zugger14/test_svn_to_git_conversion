IF NOT EXISTS (SELECT 1 FROM ixp_ssis_configurations AS isc WHERE isc.package_name = 'pipeline_cut_import')
BEGIN
	INSERT INTO ixp_ssis_configurations (package_name, package_description, config_filter_value)
	VALUES ('pipeline_cut_import', 'Pipeline Cut Import', 'PRJ_PipelineCut')
END
