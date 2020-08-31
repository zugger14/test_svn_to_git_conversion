IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_detail' AND column_name = 'assignment_type_id')
BEGIN
	ALTER TABLE state_rec_requirement_detail ADD assignment_type_id INT
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_detail' AND column_name = 'requirement_type_id')
BEGIN
	ALTER TABLE state_rec_requirement_detail ADD requirement_type_id INT
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_detail' AND column_name = 'tier_constraint_id')
BEGIN
	ALTER TABLE state_rec_requirement_detail ADD tier_constraint_id INT
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_detail' AND column_name = 'to_month')
BEGIN
	ALTER TABLE state_rec_requirement_detail ADD to_month DATETIME
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_detail' AND column_name = 'from_month')
BEGIN
	ALTER TABLE state_rec_requirement_detail ADD from_month DATETIME
END
