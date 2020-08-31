IF NOT EXISTS(SELECT 'X' FROM ixp_soap_functions WHERE ixp_soap_functions_name = 'DealImport')
BEGIN
	INSERT INTO ixp_soap_functions(ixp_soap_functions_name,ixp_soap_xml)
	VALUES('DealImport',NULL)
END

IF NOT EXISTS(SELECT 'X' FROM ixp_soap_functions WHERE ixp_soap_functions_name = 'StaticDataImport')
BEGIN
	INSERT INTO ixp_soap_functions(ixp_soap_functions_name,ixp_soap_xml)
	VALUES('StaticDataImport','<Root><PSRecordset type_id="1" code="" description="" /></Root>')
END

IF NOT EXISTS(SELECT 'X' FROM ixp_soap_functions WHERE ixp_soap_functions_name = 'ShapedDealVolumeImport')
BEGIN
	INSERT INTO ixp_soap_functions(ixp_soap_functions_name,ixp_soap_xml)
	VALUES('ShapedDealVolumeImport',NULL)
END

IF NOT EXISTS(SELECT 'X' FROM ixp_soap_functions WHERE ixp_soap_functions_name = 'PriceCurveImport')
BEGIN
	INSERT INTO ixp_soap_functions(ixp_soap_functions_name,ixp_soap_xml)
	VALUES('PriceCurveImport',NULL)
END

IF NOT EXISTS(SELECT 'X' FROM ixp_soap_functions WHERE ixp_soap_functions_name = 'MeterDataImport')
BEGIN
	INSERT INTO ixp_soap_functions(ixp_soap_functions_name,ixp_soap_xml)
	VALUES('MeterDataImport',NULL)
END

IF NOT EXISTS(SELECT 'X' FROM ixp_soap_functions WHERE ixp_soap_functions_name = 'ForecastImport')
BEGIN
	INSERT INTO ixp_soap_functions(ixp_soap_functions_name,ixp_soap_xml)
	VALUES('ForecastImport','<Root><PSRecordset profile="1" term="" hour="" value="" is_dst="" /></Root>')
END

IF NOT EXISTS(SELECT 'X' FROM ixp_soap_functions WHERE ixp_soap_functions_name = 'VolatilityImport')
BEGIN
	INSERT INTO ixp_soap_functions(ixp_soap_functions_name,ixp_soap_xml)
	VALUES('VolatilityImport',NULL)
END


IF NOT EXISTS(SELECT 'X' FROM ixp_soap_functions WHERE ixp_soap_functions_name = 'CorrelationImport')
BEGIN
	INSERT INTO ixp_soap_functions(ixp_soap_functions_name,ixp_soap_xml)
	VALUES('CorrelationImport',NULL)
END

