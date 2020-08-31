IF COL_LENGTH('regression_module_detail', 'display_name') IS NOT NULL
	EXEC sp_rename 'regression_module_detail.display_name', 'display_columns', 'COLUMN';

