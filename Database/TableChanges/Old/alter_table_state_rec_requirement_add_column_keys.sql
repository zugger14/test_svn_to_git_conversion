-- Add New Column
IF COL_LENGTH('state_rec_requirement_data', 'assignment_type_id') IS NULL
BEGIN
    ALTER TABLE state_rec_requirement_data ADD assignment_type_id INT NOT NULL
END
GO

IF COL_LENGTH('state_rec_requirement_data', 'from_month') IS NULL
BEGIN
    ALTER TABLE state_rec_requirement_data ADD from_month DATETIME NOT NULL
END
GO

IF COL_LENGTH('state_rec_requirement_data', 'to_month') IS NULL
BEGIN
    ALTER TABLE state_rec_requirement_data ADD to_month DATETIME NOT NULL
END
GO

IF COL_LENGTH('state_rec_requirement_data', 'requirement_type_id') IS NULL
BEGIN
	ALTER TABLE state_rec_requirement_data ADD requirement_type_id INT 
END


IF COL_LENGTH('state_rec_requirement_data', 'tier_constraint_id') IS NULL
BEGIN
	ALTER TABLE state_rec_requirement_data ADD tier_constraint_id INT 
END

IF COL_LENGTH('state_rec_requirement_data','rec_assignment_priority_group_id') IS NULL 
BEGIN
	ALTER TABLE state_rec_requirement_data ADD rec_assignment_priority_group_id INT	
END

IF COL_LENGTH('state_rec_requirement_data','state_rec_requirement_data_id') IS NOT NULL 
BEGIN
	ALTER TABLE state_rec_requirement_data ALTER COLUMN state_rec_requirement_data_id INT NOT NULL 
END
