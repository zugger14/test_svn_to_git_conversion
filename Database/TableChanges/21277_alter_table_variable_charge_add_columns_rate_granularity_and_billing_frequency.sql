-- Table variable_charge
IF COL_LENGTH('variable_charge','rate_granularity')IS NULL
BEGIN
	ALTER TABLE dbo.variable_charge
	ADD rate_granularity INT
END
GO

IF COL_LENGTH('variable_charge','billing_frequency') IS NULL
BEGIN
	ALTER TABLE dbo.variable_charge
	ADD billing_frequency INT
END