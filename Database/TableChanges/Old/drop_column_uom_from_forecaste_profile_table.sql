IF COL_LENGTH('forecast_profile','uom') IS NOT NULL
BEGIN
	ALTER TABLE [dbo].[forecast_profile]
	DROP COLUMN [uom]
END
