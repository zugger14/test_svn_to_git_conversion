/* Poojan Shrestha || 24.March.2009 */
/* Description : Existing Formulas in Function Editor */

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 419)
	SELECT 'Function Id already Exists'
ELSE
	INSERT INTO application_functions(function_id,function_name,function_desc,function_call)
		VALUES (419,'Existing Formulas','Existing Formulas','windowFormulaExisting');