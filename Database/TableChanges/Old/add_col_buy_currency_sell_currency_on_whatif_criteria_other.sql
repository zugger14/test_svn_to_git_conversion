/**
* alter table whatif_criteria_other to add columns buy_currency and sell_currency.
* 8/28/2012
* sangam ligal
**/
IF COL_LENGTH('whatif_criteria_other', 'buy_currency') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_other ADD buy_currency INT
END
GO

IF COL_LENGTH('whatif_criteria_other', 'sell_currency') IS NULL
BEGIN
    ALTER TABLE whatif_criteria_other ADD sell_currency INT
END
GO


