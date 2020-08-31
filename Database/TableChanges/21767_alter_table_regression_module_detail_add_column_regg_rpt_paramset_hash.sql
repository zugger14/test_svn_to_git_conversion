IF COL_LENGTH('regression_module_detail', 'regg_rpt_paramset_hash') IS NULL
BEGIN
	ALTER TABLE regression_module_detail ADD regg_rpt_paramset_hash VARCHAR(200)
END




