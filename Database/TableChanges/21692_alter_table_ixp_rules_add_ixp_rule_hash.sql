IF COL_LENGTH('ixp_rules','ixp_rule_hash') is null
BEGIN
	ALTER TABLE ixp_rules ADD ixp_rule_hash VARCHAR(50) 
END
ELSE 
	PRINT 'Column ''ixp_rule_hash'' already exists.'	
GO
