IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'assignment_type_id')
BEGIN
	ALTER TABLE state_rec_requirement_data ADD assignment_type_id INT
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'requirement_type_id')
BEGIN
	ALTER TABLE state_rec_requirement_data ADD requirement_type_id INT
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'tier_constraint_id')
BEGIN
	ALTER TABLE state_rec_requirement_data ADD tier_constraint_id INT
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'state_rec_requirement_data_id')
BEGIN
	ALTER TABLE state_rec_requirement_data ADD state_rec_requirement_data_id INT IDENTITY(1, 1) NOT NULL 
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'from_month')
BEGIN
	ALTER TABLE state_rec_requirement_data ADD from_month DATETIME
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'to_month')
BEGIN
	ALTER TABLE state_rec_requirement_data ADD to_month DATETIME
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'total_retail_sales')
BEGIN
	ALTER TABLE state_rec_requirement_data ADD total_retail_sales FLOAT
END

IF NOT EXISTS(SElECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'state_rec_requirement_data' AND column_name = 'rec_assignment_priority_group_id')
BEGIN
	ALTER TABLE state_rec_requirement_data ADD rec_assignment_priority_group_id INT
END