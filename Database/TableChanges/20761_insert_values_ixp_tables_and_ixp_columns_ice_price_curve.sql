 
delete it FROM ixp_ssis_configurations it WHERE it.package_name = 'IcePriceCurveImport'

IF NOT EXISTS (SELECT 1 FROM ixp_ssis_configurations it WHERE it.package_name = 'IcePriceCurveImport') 
BEGIN
	 INSERT INTO ixp_ssis_configurations(package_name, package_description, config_filter_value)
	 SELECT 'IcePriceCurveImport', 'Ice Price Curve Import', 'PKG_IcePriceCurveImport' 
END