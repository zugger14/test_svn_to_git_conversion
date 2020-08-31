IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131020)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131020, 'Trade Ticket', 'Trade Ticket', 10131000, 'windowTradeTicket')
 	PRINT ' Inserted 10131020 - Trade Ticket.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131020 - Trade Ticket already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131021)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131021, 'Trade Ticket Trader Sign Off', 'Trade Ticket Trader Sign Off', 10131020, NULL)
 	PRINT ' Inserted 10131021 - Trade Ticket Trader Sign Off.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131021 - Trade Ticket Trader Sign Off already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131022)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131022, 'Trade Ticket Risk Sign Off', 'Trade Ticket Risk Sign Off', 10131020, NULL)
 	PRINT ' Inserted 10131022 - Trade Ticket Risk Sign Off.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131022 - Trade Ticket Risk Sign Off already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10131023)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10131023, 'Trade Ticket Back Office Sign Off', 'Trade Ticket Back Office Sign Off', 10131020, NULL)
 	PRINT ' Inserted 10131023 - Trade Ticket Back Office Sign Off.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10131023 - Trade Ticket Back Office Sign Off already EXISTS.'
END
