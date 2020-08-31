IF COL_LENGTH('regression_module_header', 'report_paramset_hash') IS NOT NULL
	EXEC sp_rename 'regression_module_header.report_paramset_hash', 'calc_regg_rpt_paramset_hash', 'COLUMN';

