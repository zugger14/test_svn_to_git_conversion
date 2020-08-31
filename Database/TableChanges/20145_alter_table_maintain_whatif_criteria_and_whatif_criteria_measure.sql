IF COL_LENGTH('whatif_criteria_measure', 'credit') IS NULL
BEGIN
	ALTER TABLE whatif_criteria_measure ADD credit char
END
ELSE
	PRINT '''credit'' column already exists in table ''whatif_criteria_measure''.'
	
	
IF COL_LENGTH('maintain_whatif_criteria', 'counterparty_id') IS NULL
BEGIN
	ALTER TABLE maintain_whatif_criteria ADD counterparty_id int
END
ELSE
	PRINT '''counterparty_id'' column already exists in table ''maintain_whatif_criteria''.'
	
	
IF COL_LENGTH('maintain_whatif_criteria', 'debt_rating') IS NULL
BEGIN
	ALTER TABLE maintain_whatif_criteria ADD debt_rating int
END
ELSE
	PRINT '''debt_rating'' column already exists in table ''maintain_whatif_criteria''.'
	

IF COL_LENGTH('maintain_whatif_criteria', 'migration') IS NULL
BEGIN
	ALTER TABLE maintain_whatif_criteria ADD migration int
END
ELSE
	PRINT '''migration'' column already exists in table ''maintain_whatif_criteria''.'
	
