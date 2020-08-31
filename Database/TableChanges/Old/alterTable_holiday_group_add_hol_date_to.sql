IF COL_LENGTH('holiday_group', 'hol_date_to') IS NULL
BEGIN
	ALTER TABLE holiday_group ADD hol_date_to DATETIME
END
GO

