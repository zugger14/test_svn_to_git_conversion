 
delete it FROM ixp_ssis_configurations it WHERE it.package_name = 'IceDealImport'

IF NOT EXISTS (SELECT 1 FROM ixp_ssis_configurations it WHERE it.package_name = 'IceDealImport') 
BEGIN
	 INSERT INTO ixp_ssis_configurations(package_name, package_description, config_filter_value)
	 SELECT 'IceDealImport', 'Ice Deal Import', 'PKG_ICEDeal' 
END
