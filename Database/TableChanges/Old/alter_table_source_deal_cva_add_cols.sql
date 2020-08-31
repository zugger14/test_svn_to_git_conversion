/*
* alter table source_deal_cva, add cols Final_Und_Pnl, currency_name.
* sligal
* 15th april 2013
*/

IF COL_LENGTH('source_deal_cva', 'Final_Und_Pnl') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD [Final_Und_Pnl] FLOAT NULL
END
ELSE
	PRINT 'Column Final_Und_Pnl already exists in table source_deal_cva'
GO

IF COL_LENGTH('source_deal_cva', 'currency_name') IS NULL
BEGIN
    ALTER TABLE source_deal_cva ADD currency_name VARCHAR(50) NULL
END
ELSE
	PRINT 'Column currency_name already exists in table source_deal_cva'
GO
