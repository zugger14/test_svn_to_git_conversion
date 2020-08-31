
IF COL_LENGTH('contract_group', 'payment_calendar') IS  NULL
	ALTER TABLE contract_group ADD payment_calendar INT
GO

IF COL_LENGTH('contract_group', 'pnl_date') IS  NULL
	ALTER TABLE contract_group ADD pnl_date INT
GO

IF COL_LENGTH('contract_group', 'pnl_calendar') IS  NULL
	ALTER TABLE contract_group ADD pnl_calendar INT
GO


IF COL_LENGTH('contract_group_detail', 'payment_date') IS  NULL
	ALTER TABLE contract_group_detail ADD payment_date INT
GO

IF COL_LENGTH('contract_group_detail', 'payment_calendar') IS  NULL
	ALTER TABLE contract_group_detail ADD payment_calendar INT
GO

IF COL_LENGTH('contract_group_detail', 'pnl_date') IS  NULL
	ALTER TABLE contract_group_detail ADD pnl_date INT
GO

IF COL_LENGTH('contract_group_detail', 'pnl_calendar') IS  NULL
	ALTER TABLE contract_group_detail ADD pnl_calendar INT
GO

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
