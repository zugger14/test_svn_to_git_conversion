IF COL_LENGTH('whatif_criteria_measure','PFE') IS NULL
BEGIN
	ALTER TABLE whatif_criteria_measure ADD PFE CHAR(1)
END