UPDATE ixp_soap_functions 
SET ixp_soap_xml = '<Root><PSRecordset profile="1" term="" hour="" value="" is_dst="" /></Root>' 
WHERE [ixp_soap_functions_name] = 'ForecastImport'

