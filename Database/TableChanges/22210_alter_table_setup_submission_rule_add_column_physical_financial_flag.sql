IF COL_LENGTH('setup_submission_rule', 'physical_financial_flag') IS NULL
BEGIN
	ALTER TABLE setup_submission_rule
	ADD physical_financial_flag CHAR(1)
END
