--CLR import setup script.

--Setup 1: Insert script for CLR method.
IF NOT EXISTS (
		SELECT 1
		FROM ixp_clr_functions
		WHERE ixp_clr_functions_name = 'PlattsPrice'
		)
BEGIN
	INSERT INTO ixp_clr_functions (
		ixp_clr_functions_name
		, method_name
		, description
		)
	SELECT 'PlattsPrice'
		, 'PlattsPriceImporter'
		, 'Import Platts Price From Platts SFTP'
END
ELSE
	UPDATE ixf
	SET ixf.ixp_clr_functions_name = 'PlattsPrice'
		, ixf.method_name = 'PlattsPriceImporter'
		, ixf.description = 'Import Platts Price From Platts SFTP'
	--SELECT * 
	FROM ixp_clr_functions ixf
	WHERE ixp_clr_functions_name = 'PlattsPrice'

--Setup 2: Insert script to defined ixp parameters

DECLARE @clr_function_id INT 
SELECT @clr_function_id = ixp_clr_functions_id
FROM ixp_clr_functions
WHERE ixp_clr_functions_name = 'PlattsPrice'


IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_StartDate' and clr_function_id = @clr_function_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_StartDate' --parameter_name
	, 'Start Date' -- parameter_label
	, 1	 -- operator_id
	, 't' -- field_type
	, @clr_function_id -- clr_function_id
	, 'Required Field' --validation_message
	, 'y' -- insert_required
	, 'today' -- default_value

END



/*
SELECT *
FROM ixp_clr_functions
select * from ixp_parameters

*/