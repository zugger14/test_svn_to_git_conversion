/**
 Script to insert ixp parmeter.
*/

DECLARE @clr_function_id INT 
SELECT @clr_function_id = ixp_clr_functions_id
FROM ixp_clr_functions
WHERE ixp_clr_functions_name = 'Likron'

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_executedSinceDate' and clr_function_id = @clr_function_id)
BEGIN
	INSERT INTO ixp_parameters (
		  parameter_name
		, parameter_label
		, operator_id
		, field_type
		, default_value
		, default_value2
		, clr_function_id
		, default_format
		)
	SELECT 
		  'PS_executedSinceDate'
		, 'Executed Since Date'
		, 1
		, 'calendar'
		, NULL
		, NULL
		, @clr_function_id
		, 't'
END