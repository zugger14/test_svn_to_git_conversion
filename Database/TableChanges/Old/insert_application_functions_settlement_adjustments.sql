/* Poojan Shrestha || 02.April.2009 */
/* Description : Settlement Adjustments */

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 420)
	SELECT 'Function Id already Exists'
ELSE
	INSERT INTO application_functions(function_id,function_name,function_desc,function_call)
		VALUES (420,'Settlement Adjustments','Settlement Adjustments','windowSettlementAdjustments');