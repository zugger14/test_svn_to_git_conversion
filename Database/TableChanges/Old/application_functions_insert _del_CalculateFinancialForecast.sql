/*
 * Relocating the Relocate 'Calculate financial forecast' function id in the proper order of uses.
 * Relocation in TRMTracker_Essent
 */

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10182600)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES(10182600,'Calculate Financial Forecast','Calculate Financial Forecast',10182300,'windowCalculateFinancialForecast')
END


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10182600)
BEGIN
	UPDATE application_functional_users SET function_id = 10182600 WHERE function_id = 10182500
END


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10182500 AND function_name = 'Calculate Financial Forecast')
BEGIN
	DELETE FROM TRMTracker_Essent.dbo.application_functions WHERE function_id = 10182500
END




