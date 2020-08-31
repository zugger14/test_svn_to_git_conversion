IF COL_LENGTH('regression_module_detail', 'regg_type') IS NULL
	ALTER TABLE regression_module_detail ADD regg_type INT
