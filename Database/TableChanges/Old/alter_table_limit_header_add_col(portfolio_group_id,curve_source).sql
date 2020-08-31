/**
* alter table limit_header ; add column portfolio_group_id, curve_source
* sligal
* 14th may 2013
**/
IF COL_LENGTH('dbo.limit_header', 'portfolio_group_id') IS NULL
BEGIN
	ALTER TABLE dbo.limit_header
	ADD portfolio_group_id INT REFERENCES dbo.maintain_portfolio_group(portfolio_group_id)
	PRINT 'Column added.'
END
ELSE
	PRINT 'Column already exists.'
	
IF COL_LENGTH('dbo.limit_header', 'curve_source') IS NULL
BEGIN
	ALTER TABLE dbo.limit_header
	ADD curve_source INT 
	PRINT 'Column added.'
END
ELSE
	PRINT 'Column already exists.'