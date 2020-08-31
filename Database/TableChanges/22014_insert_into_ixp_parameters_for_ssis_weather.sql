DECLARE @ixp_ssis_configurations_id INT , @ixp_rules_id INT

SELECT @ixp_ssis_configurations_id = ixp_ssis_configurations_id 
FROM ixp_ssis_configurations 
WHERE package_name  = 'weather'

BEGIN
	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_DateStart' and ssis_package = @ixp_ssis_configurations_id)
	BEGIN
		INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  ssis_package, validation_message, insert_required)
		SELECT  'PS_DateStart','Start Date', 1, 'a', @ixp_ssis_configurations_id , 'Required Field', 'y'
	END
	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_DateEnd' and ssis_package = @ixp_ssis_configurations_id)
	BEGIN
		INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  ssis_package, validation_message, insert_required)
		SELECT  'PS_DateEnd','End Date', 1, 'a', @ixp_ssis_configurations_id , 'Required Field', 'y'
	END

	UPDATE ixp_parameters
	SET parameter_label = 'Start Date'
		, operator_id = 1
		, field_type = 'a'
		, ssis_package = @ixp_ssis_configurations_id
		, validation_message = 'Required Field'
		, insert_required = 'y'
	WHERE parameter_name = 'PS_DateStart'
		AND ssis_package = @ixp_ssis_configurations_id

	UPDATE ixp_parameters
	SET parameter_label = 'End Date'
		, operator_id = 1
		, field_type = 'a'
		, ssis_package = @ixp_ssis_configurations_id
		, validation_message = 'Required Field'
		, insert_required = 'y'
	WHERE parameter_name = 'PS_DateEnd'
		AND ssis_package = @ixp_ssis_configurations_id


END 

