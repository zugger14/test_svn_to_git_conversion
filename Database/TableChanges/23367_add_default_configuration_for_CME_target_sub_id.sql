-- Default CME TargetSubID Value was missing from configuration, though it can be configured from application
-- Added to avoid issue of cme configuration this configuration is required to capture report from CME
IF NOT EXISTS(SELECT 1 FROM interface_configuration WHERE interface_id= 109902 AND variable_name = 'TargetSubID')
BEGIN
	INSERT INTO interface_configuration (interface_id, configuration_type, variable_name,variable_value) VALUES (109902, '[SESSION]', 'TargetSubID', '')
END
-- Update Default Value to STP
UPDATE interface_configuration SET variable_value = 'STP' WHERE interface_id = 109902 AND configuration_type = '[SESSION]' AND variable_name = 'TargetSubID'
GO