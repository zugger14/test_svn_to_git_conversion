--Function ID for Import from System File
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131361)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131361, 'Import from System File', 'Import from System File', 10131300, NULL)
 	PRINT ' Inserted 10131361 - Import from System File.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131361 - Import from System File already EXISTS.'
END
--Function ID for Book Attribute (4000)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131362)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131362, 'Import from System File - Book Attribute (4000)', 'Book Attribute', 10131361, NULL)
 	PRINT ' Inserted 10131362 - Import from System File - Book Attribute (4000).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131362 - Import from System File - Book Attribute (4000) already EXISTS.'
END
--Function ID for Commodity (4001)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131363)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131363, 'Import from System File - Commodity (4001)', 'Commodity', 10131361, NULL)
 	PRINT ' Inserted 10131363 - Import from System File - Commodity (4001).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131363 - Import from System File - Commodity (4001) already EXISTS.'
END
--Function ID for Counterparty (4002)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131364)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131364, 'Import from System File - Counterparty (4002)', 'Counterparty', 10131361, NULL)
 	PRINT ' Inserted 10131364 - Import from System File - Counterparty (4002).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131364 - Import from System File - Counterparty (4002) already EXISTS.'
END
--Function ID for Currency (4003)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131365)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131365, 'Import from System File - Currency (4003)', 'Currency', 10131361, NULL)
 	PRINT ' Inserted 10131365 - Import from System File - Currency (4003).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131365 - Import from System File - Currency (4003) already EXISTS.'
END
--Function ID for Deal Detail (4005)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131366)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131366, 'Import from System File - Deal Detail (4005)', 'Deal Detail', 10131361, NULL)
 	PRINT ' Inserted 10131366 - Import from System File - Deal Detail (4005).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131366 - Import from System File - Deal Detail (4005) already EXISTS.'
END
--Function ID for PNL (4006)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131367)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131367, 'Import from System File - PNL (4006)', 'PNL', 10131361, NULL)
 	PRINT ' Inserted 10131367 - Import from System File - PNL (4006).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131367 - Import from System File - PNL (4006) already EXISTS.'
END
--Function ID for Deal Type (4007)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131368)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131368, 'Import from System File - Deal Type (4007)', 'Deal Type', 10131361, NULL)
 	PRINT ' Inserted 10131368 - Import from System File - Deal Type (4007).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131368 - Import from System File - Deal Type (4007) already EXISTS.'
END
--Function ID for Curves (4008)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131369)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131369, 'Import from System File - Curves (4008)', 'Curves', 10131361, NULL)
 	PRINT ' Inserted 10131369 - Import from System File - Curves (4008).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131369 - Import from System File - Curves (4008) already EXISTS.'
END
--Function ID for Curve Def (4009)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131370)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131370, 'Import from System File - Curve Def (4009)', 'Curve Def', 10131361, NULL)
 	PRINT ' Inserted 10131370 - Import from System File - Curve Def (4009).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131370 - Import from System File - Curve Def (4009) already EXISTS.'
END
--Function ID for Trader (4010)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131371)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131371, 'Import from System File - Trader (4010)', 'Trader', 10131361, NULL)
 	PRINT ' Inserted 10131371 - Import from System File - Trader (4010).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131371 - Import from System File - Trader (4010) already EXISTS.'
END
--Function ID for UOM (4011)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131372)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131372, 'Import from System File - UOM (4011)', 'UOM', 10131361, NULL)
 	PRINT ' Inserted 10131372 - Import from System File - UOM (4011).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131372 - Import from System File - UOM (4011) already EXISTS.'
END
--Function ID for Contract (4016)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131373)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131373, 'Import from System File - Contract (4016)', 'Contract', 10131361, NULL)
 	PRINT ' Inserted 10131373 - Import from System File - Contract (4016).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131373 - Import from System File - Contract (4016) already EXISTS.'
END
--Function ID for Default Probabilty (4024)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131374)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131374, 'Import from System File - Default Probabilty (4024)', 'Default Probabilty', 10131361, NULL)
 	PRINT ' Inserted 10131374 - Import from System File - Default Probabilty (4024).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131374 - Import from System File - Default Probabilty (4024) already EXISTS.'
END
--Function ID for Default Recovery Rate (4025)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131375)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131375, 'Import from System File - Default Recovery Rate (4025)', 'Default Recovery Rate', 10131361, NULL)
 	PRINT ' Inserted 10131375 - Import from System File - Default Recovery Rate (4025).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131375 - Import from System File - Default Recovery Rate (4025) already EXISTS.'
END
--Function ID for curve_correlation (4026)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131376)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131376, 'Import from System File - curve_correlation (4026)', 'curve_correlation', 10131361, NULL)
 	PRINT ' Inserted 10131376 - Import from System File - curve_correlation (4026).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131376 - Import from System File - curve_correlation (4026) already EXISTS.'
END
--Function ID for curve_volatility (4027)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131377)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131377, 'Import from System File - curve_volatility (4027)', 'curve_volatility', 10131361, NULL)
 	PRINT ' Inserted 10131377 - Import from System File - curve_volatility (4027).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131377 - Import from System File - curve_volatility (4027) already EXISTS.'
END
--Function ID for source_deal_detail_trm (4028)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131378)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131378, 'Import from System File - source_deal_detail_trm (4028)', 'source_deal_detail_trm', 10131361, NULL)
 	PRINT ' Inserted 10131378 - Import from System File - source_deal_detail_trm (4028).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131378 - Import from System File - source_deal_detail_trm (4028) already EXISTS.'
END
--Function ID for Deal_SNWA (4029)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131379)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131379, 'Import from System File - Deal_SNWA (4029)', 'Deal_SNWA', 10131361, NULL)
 	PRINT ' Inserted 10131379 - Import from System File - Deal_SNWA (4029).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131379 - Import from System File - Deal_SNWA (4029) already EXISTS.'
END
--Function ID for Expected Return (4032)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131380)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131380, 'Import from System File - Expected Return (4032)', 'Expected Return', 10131361, NULL)
 	PRINT ' Inserted 10131380 - Import from System File - Expected Return (4032).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131380 - Import from System File - Expected Return (4032) already EXISTS.'
END
--Function ID for Shaped Deal Houly Data (4037)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131381)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131381, 'Import from System File - Shaped Deal Houly Data (4037)', 'Shaped Deal Houly Data', 10131361, NULL)
 	PRINT ' Inserted 10131381 - Import from System File - Shaped Deal Houly Data (4037).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131381 - Import from System File - Shaped Deal Houly Data (4037) already EXISTS.'
END

--Function ID for Import from System Files - Deal Import (4055)
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131382)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131382, 'Import from System Files - Deal Import (4055)', 'Deal Import', 10131361, NULL)
 	PRINT ' Inserted 10131348 - Import from System Files - Deal Import (4055).'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131348 - Import from System Files - Deal Import (4055) already EXISTS.'
END