-- Table transportation_rate_schedule
IF COL_LENGTH('transportation_rate_schedule','begin_date')IS NULL
BEGIN
	ALTER TABLE dbo.transportation_rate_schedule
	ADD begin_date DATE
END
GO

IF COL_LENGTH('transportation_rate_schedule','end_date') IS NULL
BEGIN
	ALTER TABLE dbo.transportation_rate_schedule
	ADD end_date DATE
END

IF COL_LENGTH('transportation_rate_schedule','zone_from') IS NULL
BEGIN
	ALTER TABLE dbo.transportation_rate_schedule
	ADD zone_from INT
END

IF COL_LENGTH('transportation_rate_schedule','zone_to') IS NULL
BEGIN
	ALTER TABLE dbo.transportation_rate_schedule
	ADD zone_to INT
END