
IF COL_LENGTH('contract_group_detail', 'calc_aggregation') IS NOT NULL
BEGIN
    ALTER TABLE contract_group_detail ALTER COLUMN calc_aggregation VARCHAR(100) NULL
    PRINT 'Column contract_group_detail.calc_aggregation updated.'
END
GO

UPDATE contract_group_detail SET calc_aggregation= CASE WHEN calc_aggregation='y' THEN 19001 WHEN calc_aggregation='n' THEN 19000 ELSE calc_aggregation END

GO

IF COL_LENGTH('contract_group_detail', 'calc_aggregation') IS NOT NULL
BEGIN
    ALTER TABLE contract_group_detail ALTER COLUMN calc_aggregation INT NULL
    PRINT 'Column contract_group_detail.calc_aggregation updated.'
END
GO
