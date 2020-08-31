IF COL_LENGTH('contract_group_detail', 'calc_aggregation') IS NULL
BEGIN
	ALTER TABLE contract_group_detail add calc_aggregation CHAR(1)

	PRINT 'Column contract_group_detail.calc_aggregation added.'
END
ELSE
BEGIN
	PRINT 'Column contract_group_detail.calc_aggregation already exists.'
END
GO 

