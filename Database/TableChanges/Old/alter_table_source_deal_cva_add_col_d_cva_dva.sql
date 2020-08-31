IF COL_LENGTH('source_deal_cva', 'd_cva') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD [d_cva] FLOAT
END
ELSE
	PRINT 'Column d_cva already exists in table source_deal_cva'
GO

IF COL_LENGTH('source_deal_cva', 'd_dva') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD d_dva FLOAT
END
ELSE
	PRINT 'Column d_dva already exists in table source_deal_cva'
GO

IF COL_LENGTH('source_deal_cva', 'credit_adjustment_mtm') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD credit_adjustment_mtm FLOAT
END
ELSE
	PRINT 'Column credit_adjustment_mtm already exists in table source_deal_cva'
GO

IF COL_LENGTH('source_deal_cva', 'adjusted_discounted_mtm') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD adjusted_discounted_mtm FLOAT
END
ELSE
	PRINT 'Column adjusted_discounted_mtm already exists in table source_deal_cva'
GO