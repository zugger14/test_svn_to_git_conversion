--Table variable_charge
IF COL_LENGTH('variable_charge','begin_date')IS NULL
BEGIN
	ALTER TABLE dbo.variable_charge
	ADD begin_date DATE
END
GO

IF COL_LENGTH('variable_charge','end_date') IS NULL
BEGIN
	ALTER TABLE dbo.variable_charge
	ADD end_date DATE
END
IF COL_LENGTH('variable_charge','formula_name') IS NULL
BEGIN
	ALTER TABLE dbo.variable_charge
	ADD formula_name VARCHAR(5000)
END