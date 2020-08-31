IF COL_LENGTH('generator_data','generator_config_value_id') IS NULL
	alter table dbo.generator_data add generator_config_value_id int