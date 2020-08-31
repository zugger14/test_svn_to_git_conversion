/* update function_name, function_desc,function_call name of Maintain What-If Scenario(10183300) 
* required as issue occured due to dynamic menu feature.
* 'Maintain What-If Scenario' window was not able to open.
* 1/30/2013
* */
IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10183300)
BEGIN
	UPDATE application_functions
	SET	function_name = 'Maintain What-If Scenario',
		function_desc = 'Maintain What-If Scenario',
		function_call = 'windowMaintainWhatIfScenario'
	WHERE function_id = 10183300
END
ELSE
	PRINT 'Function ID 10183300 does not exists.'