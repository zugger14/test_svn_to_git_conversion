IF COL_LENGTH('source_remit_non_standard','energy_commodity') IS NOT NULL
BEGIN
	ALTER TABLE [source_remit_non_standard]
	ALTER COLUMN [energy_commodity] VARCHAR(20) NULL
END

IF COL_LENGTH('source_remit_non_standard','delivery_point_or_zone') IS NOT NULL
BEGIN
	ALTER TABLE [source_remit_non_standard]
	ALTER COLUMN [delivery_point_or_zone] VARCHAR(500) NULL
END

