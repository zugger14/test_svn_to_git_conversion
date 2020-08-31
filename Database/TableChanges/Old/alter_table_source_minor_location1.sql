IF COL_LENGTH('source_minor_location', 'postal_code') IS NULL
	ALTER TABLE source_minor_location ADD postal_code VARCHAR(8)
GO 

IF COL_LENGTH('source_minor_location', 'province') IS NULL
	ALTER TABLE source_minor_location ADD province VARCHAR(100)
GO 

IF COL_LENGTH('source_minor_location', 'physical_shipper') IS NULL
	ALTER TABLE source_minor_location ADD physical_shipper VARCHAR(50)
GO 

IF COL_LENGTH('source_minor_location', 'sicc_code') IS NULL
	ALTER TABLE source_minor_location ADD sicc_code VARCHAR(50)
GO 

IF COL_LENGTH('source_minor_location', 'profile_code') IS NULL
	ALTER TABLE source_minor_location ADD profile_code VARCHAR(50)
GO 

IF COL_LENGTH('source_minor_location', 'nominatorsapcode') IS NULL
	ALTER TABLE source_minor_location ADD nominatorsapcode VARCHAR(50)
GO 

IF COL_LENGTH('source_minor_location', 'forecast_needed') IS NULL
	ALTER TABLE source_minor_location ADD forecast_needed CHAR(1)
GO 

IF COL_LENGTH('source_minor_location', 'forecasting_group') IS NULL
	ALTER TABLE source_minor_location ADD forecasting_group VARCHAR(50)
GO 

IF COL_LENGTH('source_minor_location', 'external_profile') IS NULL
	ALTER TABLE source_minor_location ADD external_profile VARCHAR(50)
GO 

IF COL_LENGTH('source_minor_location', 'calculation_method') IS NULL
	ALTER TABLE source_minor_location ADD calculation_method CHAR(1)
GO 

IF COL_LENGTH('source_minor_location', 'category') IS NULL
	ALTER TABLE source_minor_location ADD category VARCHAR(50)
GO 

IF COL_LENGTH('source_minor_location', 'category') IS NOT NULL
	ALTER TABLE source_minor_location DROP COLUMN category
GO 


IF COL_LENGTH('source_minor_location', 'postal_code') IS NOT NULL
BEGIN
    ALTER TABLE source_minor_location ALTER COLUMN postal_code VARCHAR(50)
END
GO

IF COL_LENGTH('source_minor_location', 'calculation_method') IS NOT NULL
BEGIN
    ALTER TABLE source_minor_location ALTER COLUMN calculation_method VARCHAR(50)
END
GO

IF COL_LENGTH('source_minor_location', 'calc_method') IS NOT NULL
BEGIN
    ALTER TABLE source_minor_location DROP COLUMN calc_method
END
GO

IF COL_LENGTH('source_minor_location', 'nominator_sap_code') IS NOT NULL
BEGIN
    ALTER TABLE source_minor_location DROP COLUMN nominator_sap_code
END
GO