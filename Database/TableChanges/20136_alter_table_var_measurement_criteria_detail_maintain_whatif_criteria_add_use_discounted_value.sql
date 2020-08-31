IF COL_LENGTH('var_measurement_criteria_detail', 'use_discounted_value') IS NULL
BEGIN
	ALTER TABLE var_measurement_criteria_detail ADD use_discounted_value char
END
ELSE
	PRINT 'use_discounted_value column already exists.'


IF COL_LENGTH('maintain_whatif_criteria', 'use_discounted_value') IS NULL
BEGIN
	ALTER TABLE maintain_whatif_criteria ADD use_discounted_value char
END
ELSE
	PRINT 'use_discounted_value column already exists.'