IF COL_LENGTH('ixp_rules', 'ixp_rule_hash') IS NOT NULL 
ALTER TABLE ixp_rules ALTER COLUMN ixp_rule_hash VARCHAR(50) NOT NULL
	