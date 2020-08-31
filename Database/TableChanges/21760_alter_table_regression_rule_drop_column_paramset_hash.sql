IF COL_LENGTH('regression_rule', 'paramset_hash') IS NOT NULL
BEGIN
	ALTER TABLE regression_rule DROP COLUMN paramset_hash
END


