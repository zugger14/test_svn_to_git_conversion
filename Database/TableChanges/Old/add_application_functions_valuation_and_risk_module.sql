/**
* sligal
* date:6/20/2012
* purpose: added application functions for valuation and risk analysis module (issue ID:6225)
**/

-- Maintain Portfolio Group
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183200, 'Maintain Portfolio Group', 'Maintain Portfolio Group', 10180000, 'windowMaintainPortfolioGroup')
 	PRINT ' Inserted 10183200 - Maintain Portfolio Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183200 - Maintain Portfolio Group already EXISTS.'
END


-- Maintain Portfolio Group IU
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183210)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183210, 'Maintain Portfolio Group IU', 'Maintain Portfolio Group IU', 10183200, 'windowMaintainPortfolioGroupIU')
 	PRINT ' Inserted 10183210 - Maintain Portfolio Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183210 - Maintain Portfolio Group IU already EXISTS.'
END



-- Maintain Portfolio Group Delete
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183211)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183211, 'Maintain Portfolio Group Delete', 'Maintain Portfolio Group Delete', 10183200, NULL)
 	PRINT ' Inserted 10183211 - Maintain Portfolio Group Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183211 - Maintain Portfolio Group Delete already EXISTS.'
END


-- Maintain Scenario
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183300)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183300, 'Maintain Scenario', 'Maintain Scenario', 10180000, 'windowManitainScenario')
 	PRINT ' Inserted 10183300 - Maintain Scenario.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183300 - Maintain Scenario already EXISTS.'
END


-- Maintain Scenario IU
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183310)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183310, 'Maintain Scenario IU', 'Maintain Scenario IU', 10183300, 'windowMaintainScenarioIU')
 	PRINT ' Inserted 10183310 - Maintain Scenario IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183310 - Maintain Scenario IU already EXISTS.'
END


-- Maintain Scenario Delete
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183311)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183311, 'Maintain Scenario Delete', 'Maintain Scenario Delete', 10183300, NULL)
 	PRINT ' Inserted 10183311 - Maintain Scenario Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183311 - Maintain Scenario Delete already EXISTS.'
END


-- Maintain What-If Criteria
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183400)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183400, 'Maintain What-If Criteria', 'Maintain What-If Criteria', 10180000, 'windowMaintainWhatIfCriteria')
 	PRINT ' Inserted 10183400 - Maintain What-If Criteria.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183400 - Maintain What-If Criteria already EXISTS.'
END



-- Maintain What-If Criteria IU
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183410)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183410, 'Maintain What-If Criteria IU', 'Maintain What-If Criteria IU', 10183400, 'windowMaintainWhatIfCriteriaIU')
 	PRINT ' Inserted 10183410 - Maintain What-If Criteria IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183410 - Maintain What-If Criteria IU already EXISTS.'
END



-- Maintain What-If Criteria Delete
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183411)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183411, 'Maintain What-If Criteria Delete', 'Maintain What-If Criteria Delete', 10183400, NULL)
 	PRINT ' Inserted 10183411 - Maintain What-If Criteria Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183411 - Maintain What-If Criteria Delete already EXISTS.'
END

-- Run What-If Analysis Report
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10183500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10183500, 'Run What-If Analysis Report', 'Run What-If Analysis Report', 10180000, 'windowRunWhatIfAnalysisReport')
 	PRINT ' Inserted 10183500 - Run What-If Analysis Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10183500 - Run What-If Analysis Report already EXISTS.'
END
