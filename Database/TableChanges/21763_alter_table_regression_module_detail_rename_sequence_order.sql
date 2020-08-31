IF COL_LENGTH('regression_module_detail', 'sequence_order') IS NOT NULL
	EXEC sp_rename 'regression_module_detail.sequence_order', 'data_order', 'COLUMN';