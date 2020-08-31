DECLARE @ixp_clr_functions_id INT

SELECT @ixp_clr_functions_id = ixp_clr_functions_id 
FROM ixp_clr_functions 
WHERE method_name  = 'LocusEnergyMntlyVolsImporter'

IF (@ixp_clr_functions_id IS NOT NULL OR @ixp_clr_functions_id <> '') 
BEGIN
	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_DateStart' AND clr_function_id = @ixp_clr_functions_id)
	BEGIN
		INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required)
		SELECT 'PS_DateStart','Start Date', 1, 'a', @ixp_clr_functions_id , 'Required Field', 'y'
	END
	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_DateEnd' AND clr_function_id = @ixp_clr_functions_id)
	BEGIN
		INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required)
		SELECT 'PS_DateEnd','End Date', 1, 'a', @ixp_clr_functions_id , 'Required Field', 'y'
	END
	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_PlantId' AND clr_function_id = @ixp_clr_functions_id)
	BEGIN
		INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, grid_name)
		SELECT 'PS_PlantId','Plant ID', 1, 'm', @ixp_clr_functions_id , 'Required Field', 'y', 'browse_locus_energy_generator'
	END
END