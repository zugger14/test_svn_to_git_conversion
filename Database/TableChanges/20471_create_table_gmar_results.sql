IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[gmar_results]') AND TYPE IN (N'U'))
BEGIN
	PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE gmar_results(id INT IDENTITY(1,1),
		criteria_id INT,
		as_of_date DATETIME,
		positive_cashflow FLOAT,
		negative_cashflow FLOAT,
		total_cashflow FLOAT,
		gross_margin FLOAT,
		GMaR FLOAT,
		currency_id INT,
		create_user VARCHAR(50),
		create_ts DATETIME)
PRINT 'Table Successfully Created'
END	
GO