IF COL_LENGTH('interface_configuration_detail','target_sub_id') IS NULL
	ALTER TABLE interface_configuration_detail ADD target_sub_id VARCHAR(1000)
GO