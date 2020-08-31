IF COL_LENGTH(N'testing.pre_post_configuration', N'regression_group_value_id') IS NULL
	ALTER TABLE testing.pre_post_configuration ADD regression_group_value_id INT  