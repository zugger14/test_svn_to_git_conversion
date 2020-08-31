-- Table transportation_rate_schedule
IF COL_LENGTH('transportation_rate_schedule','rate_granularity')IS NULL
BEGIN
	ALTER TABLE dbo.transportation_rate_schedule
	ADD rate_granularity INT
END
GO

IF COL_LENGTH('transportation_rate_schedule','billing_frequency') IS NULL
BEGIN
	ALTER TABLE dbo.transportation_rate_schedule
	ADD billing_frequency INT
END