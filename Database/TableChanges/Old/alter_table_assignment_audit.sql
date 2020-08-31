IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'assignment_audit' AND column_name = 'Tier')
BEGIN
	ALTER TABLE assignment_audit ADD Tier INT
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'assignment_audit' AND column_name = 'committed')
BEGIN
	ALTER TABLE assignment_audit ADD committed BIT
END
	
IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'assignment_audit' AND column_name = 'org_assigned_volume')
BEGIN
	ALTER TABLE assignment_audit ADD org_assigned_volume NUMERIC(38, 20)
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'assignment_audit' AND column_name = 'compliance_group_id')
BEGIN
	ALTER TABLE assignment_audit ADD compliance_group_id INT
END	
