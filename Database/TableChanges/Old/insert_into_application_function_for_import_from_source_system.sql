--Function ID For Import All Data

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131300, 'Import All Data', 'Import All Data', 10130000, NULL)
 	PRINT ' Inserted 10131300 - Import All Data.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131300 - Import All Data already EXISTS.'
END

--Function ID For Import from Source System
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131301)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131301, 'Import from Source System', 'Import from Source System', 10131300, NULL)
 	PRINT ' Inserted 10131301 - Import from Source System.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131301 - Import from Source System already EXISTS.'
END
--Function ID For Book Attribute
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131302)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131302, 'Import from Source System - Book Attribute', 'Book Attribute', 10131301, NULL)
 	PRINT ' Inserted 10131302 - Import from Source System - Book Attribute.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131302 - Import from Source System - Book Attribute already EXISTS.'
END
--Function ID For Commodity
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131303)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131303, 'Import from Source System - Commodity', 'Commodity', 10131301, NULL)
 	PRINT ' Inserted 10131303 - Import from Source System - Commodity.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131303 - Import from Source System - Commodity already EXISTS.'
END
--Function ID For Counterparty
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131304)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131304, 'Import from Source System - Counterparty', 'Counterparty', 10131301, NULL)
 	PRINT ' Inserted 10131304 - Import from Source System - Counterparty.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131304 - Import from Source System - Counterparty already EXISTS.'
END
--Function ID For Currency
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131305)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131305, 'Import from Source System - Currency', 'Currency', 10131301, NULL)
 	PRINT ' Inserted 10131305 - Import from Source System - Currency.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131305 - Import from Source System - Currency already EXISTS.'
END
--Function ID For Deal Detail
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131306)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131306, 'Import from Source System - Deal Detail', 'Deal Detail', 10131301, NULL)
 	PRINT ' Inserted 10131306 - Import from Source System - Deal Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131306 - Import from Source System - Deal Detail already EXISTS.'
END
--Function ID For PNL
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131307)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131307, 'Import from Source System - PNL', 'PNL', 10131301, NULL)
 	PRINT ' Inserted 10131307 - Import from Source System - PNL.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131307 - Import from Source System - PNL already EXISTS.'
END
--Function ID For Deal Type
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131308)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131308, 'Import from Source System - Deal Type', 'Deal Type', 10131301, NULL)
 	PRINT ' Inserted 10131308 - Import from Source System - Deal Type.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131308 - Import from Source System - Deal Type already EXISTS.'
END
--Function ID For Curves
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131309)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131309, 'Import from Source System - Curves', 'Curves', 10131301, NULL)
 	PRINT ' Inserted 10131309 - Import from Source System - Curves.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131309 - Import from Source System - Curves already EXISTS.'
END
--Function ID For Curve Def
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131310)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131310, 'Import from Source System - Curve Def', 'Curve Def', 10131301, NULL)
 	PRINT ' Inserted 10131310 - Import from Source System - Curve Def.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131310 - Import from Source System - Curve Def already EXISTS.'
END
--Function ID For Trader
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131311)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131311, 'Import from Source System - Trader', 'Trader', 10131301, NULL)
 	PRINT ' Inserted 10131311 - Import from Source System - Trader.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131311 - Import from Source System - Trader already EXISTS.'
END
--Function ID For UOM
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131312)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131312, 'Import from Source System - UOM', 'UOM', 10131301, NULL)
 	PRINT ' Inserted 10131312 - Import from Source System - UOM.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131312 - Import from Source System - UOM already EXISTS.'
END
--Function ID For Trayport
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131313)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131313, 'Import from Source System - Trayport', 'Trayport', 10131301, NULL)
 	PRINT ' Inserted 10131313 - Import from Source System - Trayport.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131313 - Import from Source System - Trayport already EXISTS.'
END
--Function ID For Contract
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131314)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131314, 'Import from Source System - Contract', 'Contract', 10131301, NULL)
 	PRINT ' Inserted 10131314 - Import from Source System - Contract.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131314 - Import from Source System - Contract already EXISTS.'
END
--Function ID For Shaped Hourly Data Import
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131315)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131315, 'Import from Source System - Shaped Hourly Data Import', 'Shaped Hourly Data Import', 10131301, NULL)
 	PRINT ' Inserted 10131315 - Import from Source System - Shaped Hourly Data Import.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131315 - Import from Source System - Shaped Hourly Data Import already EXISTS.'
END
--Function ID For Deal Detail Hour
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131316)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131316, 'Import from Source System - Deal Detail Hour', 'Deal Detail Hour', 10131301, NULL)
 	PRINT ' Inserted 10131316 - Import from Source System - Deal Detail Hour.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131316 - Import from Source System - Deal Detail Hour already EXISTS.'
END
----Function ID For Pratos
--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131317)
--BEGIN
-- 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
--	VALUES (10131317, 'Import from Source System - Pratos', 'Pratos', 10131301, NULL)
-- 	PRINT ' Inserted 10131317 - Import from Source System - Pratos.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10131317 - Import from Source System - Pratos already EXISTS.'
--END
----Function ID For short_term_forecast
--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131318)
--BEGIN
-- 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
--	VALUES (10131318, 'Import from Source System - short_term_forecast', 'short_term_forecast', 10131301, NULL)
-- 	PRINT ' Inserted 10131318 - Import from Source System - short_term_forecast.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10131318 - Import from Source System - short_term_forecast already EXISTS.'
--END
----Function ID For eBase
--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131319)
--BEGIN
-- 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
--	VALUES (10131319, 'Import from Source System - eBase', 'eBase', 10131301, NULL)
-- 	PRINT ' Inserted 10131319 - Import from Source System - eBase.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10131319 - Import from Source System - eBase already EXISTS.'
--END
----Function ID For Ecm_Response
--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131320)
--BEGIN
-- 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
--	VALUES (10131320, 'Import from Source System - Ecm_Response', 'Ecm_Response', 10131301, NULL)
-- 	PRINT ' Inserted 10131320 - Import from Source System - Ecm_Response.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10131320 - Import from Source System - Ecm_Response already EXISTS.'
--END
----Function ID For Ecm_Request
--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131321)
--BEGIN
-- 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
--	VALUES (10131321, 'Import from Source System - Ecm_Request', 'Ecm_Request', 10131301, NULL)
-- 	PRINT ' Inserted 10131321 - Import from Source System - Ecm_Request.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10131321 - Import from Source System - Ecm_Request already EXISTS.'
--END
----Function ID For DSI price curve request value
--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131322)
--BEGIN
-- 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
--	VALUES (10131322, 'Import from Source System - DSI price curve request value', 'DSI price curve request value', 10131301, NULL)
-- 	PRINT ' Inserted 10131322 - Import from Source System - DSI price curve request value.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10131322 - Import from Source System - DSI price curve request value already EXISTS.'
--END
----Function ID For DSI price curve response value
--IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131323)
--BEGIN
-- 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
--	VALUES (10131323, 'Import from Source System - DSI price curve response value', 'DSI price curve response value', 10131301, NULL)
-- 	PRINT ' Inserted 10131323 - Import from Source System - DSI price curve response value.'
--END
--ELSE
--BEGIN
--	PRINT 'Application FunctionID 10131323 - Import from Source System - DSI price curve response value already EXISTS.'
--END
