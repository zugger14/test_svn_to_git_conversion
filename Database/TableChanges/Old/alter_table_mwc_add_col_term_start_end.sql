/**
* alter table maintain_whatif_criteria, add  term_start, term_end for new enhancement of tenor attached with criteria.
* 3 jan 2014
**/
	
IF COL_LENGTH ('maintain_whatif_criteria', 'term_start') IS NULL
BEGIN
	ALTER TABLE maintain_whatif_criteria ADD term_start DATETIME NULL	
END
ELSE
	PRINT 'Column already exists.'

IF COL_LENGTH ('maintain_whatif_criteria', 'term_end') IS NULL
BEGIN
	ALTER TABLE maintain_whatif_criteria ADD term_end DATETIME NULL	
END
ELSE
	PRINT 'Column already exists.'
	
--update previous values for tenor_from, tenor_to, tenor_type to NULL
IF COL_LENGTH ('maintain_whatif_criteria', 'tenor_from') IS NOT NULL
BEGIN
	UPDATE maintain_whatif_criteria SET tenor_from = NULL
END
IF COL_LENGTH ('maintain_whatif_criteria', 'tenor_to') IS NOT NULL
BEGIN
	UPDATE maintain_whatif_criteria SET tenor_to = NULL
END
IF COL_LENGTH ('maintain_whatif_criteria', 'tenor_type') IS NOT NULL
BEGIN
	UPDATE maintain_whatif_criteria SET tenor_type = NULL
END
		
		