DECLARE @ixp_ssis_configurations_id INT , @ixp_rules_id INT

SELECT @ixp_ssis_configurations_id = ixp_ssis_configurations_id 
FROM ixp_ssis_configurations 
WHERE package_name  = 'weather'

SELECT @ixp_rules_id = ixp_rules_id 
FROM ixp_rules 
WHERE ixp_rules_name  = 'TimeSeries Weather Data'


IF @ixp_rules_id IS NOT NULL
BEGIN
	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_DateStart' and ssis_package = @ixp_ssis_configurations_id)
	BEGIN
		INSERT INTO ixp_parameters(ixp_rules_id, parameter_name, parameter_label, operator_id, field_type,  ssis_package, validation_message, insert_required)
		SELECT @ixp_rules_id, 'PS_DateStart','Start Date', 1, 'a', @ixp_ssis_configurations_id , 'Required Field', 'y'
	END
	IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_DateEnd' and ssis_package = @ixp_ssis_configurations_id)
	BEGIN
		INSERT INTO ixp_parameters(ixp_rules_id, parameter_name, parameter_label, operator_id, field_type,  ssis_package, validation_message, insert_required)
		SELECT @ixp_rules_id, 'PS_DateEnd','End Date', 1, 'a', @ixp_ssis_configurations_id , 'Required Field', 'y'
	END
END 

