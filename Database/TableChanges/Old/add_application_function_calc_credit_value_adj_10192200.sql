/**
* insert menu 'Calculate Credit Value Adjustment' under module 'Credit Risk And Analysis'.
* 2013/03/27
* sligal
**/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10192200)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10192200, 'Calculate Credit Value Adjustment', 'Calculate Credit Value Adjustment', 10190000, 'windowCalcCreditValueAdjustment')
 	PRINT ' Inserted 10192200 - Calculate Credit Value Adjustment.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10192200 - Calculate Credit Value Adjustment already EXISTS.'
END
GO

/**
* insert menu 'Run Credit Value Adjustment Report' under module 'Credit Risk And Analysis'.
* 2013/04/01
* sligal
**/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10192300)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call, document_path)
	VALUES (10192300, 'Run Credit Value Adjustment Report', 'Run Credit Value Adjustment Report', 10190000, 'windowRunCreditValueAdjustmentReport', 'Middle Office/Credit Risk and Analysis/Run Calculate Credit Value Adjustments Report.htm')
 	PRINT ' Inserted 10192300 - Run Credit Value Adjustment Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10192300 - Run Credit Value Adjustment Report already EXISTS.'
END

