/*
* add currency_id column on pfe_results
* 25 oct 2013
*/
IF COL_LENGTH(N'pfe_results', 'currency_id') IS NULL
BEGIN
    ALTER TABLE pfe_results ADD currency_id INT REFERENCES dbo.source_currency(source_currency_id)
END
ELSE
	PRINT 'column already exists'
	
IF COL_LENGTH(N'pfe_results_whatif', 'currency_id') IS NULL
BEGIN
    ALTER TABLE pfe_results_whatif ADD currency_id INT REFERENCES dbo.source_currency(source_currency_id)
END
ELSE
	PRINT 'column already exists'	
	
IF COL_LENGTH(N'pfe_results_term_wise', 'currency_id') IS NULL
BEGIN
    ALTER TABLE pfe_results_term_wise ADD currency_id INT REFERENCES dbo.source_currency(source_currency_id)
END
ELSE
	PRINT 'column already exists'
	
IF COL_LENGTH(N'pfe_results_term_wise_whatif', 'currency_id') IS NULL
BEGIN
    ALTER TABLE pfe_results_term_wise_whatif ADD currency_id INT REFERENCES dbo.source_currency(source_currency_id)
END
ELSE
	PRINT 'column already exists'	