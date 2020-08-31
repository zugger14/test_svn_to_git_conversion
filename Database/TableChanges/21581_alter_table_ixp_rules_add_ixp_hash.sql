IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'ixp_rules' and column_name  = 'ixp_rule_hash')
BEGIN
	ALTER TABLE ixp_rules ADD ixp_rule_hash VARCHAR(50)
END