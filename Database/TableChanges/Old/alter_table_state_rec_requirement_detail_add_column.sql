IF COL_LENGTH('state_rec_requirement_detail', 'requirement_type_id') IS NULL
BEGIN
	ALTER TABLE state_rec_requirement_detail ADD requirement_type_id INT 
END
GO 

IF COL_LENGTH('state_rec_requirement_detail', 'tier_constraint_id') IS NULL
BEGIN
	ALTER TABLE state_rec_requirement_detail ADD tier_constraint_id INT 
END
GO 

IF COL_LENGTH('state_rec_requirement_detail', 'to_month') IS NULL
BEGIN
    ALTER TABLE state_rec_requirement_detail ADD to_month DATETIME 
END
GO

IF COL_LENGTH('state_rec_requirement_detail', 'from_month') IS NULL
BEGIN
    ALTER TABLE state_rec_requirement_detail ADD from_month DATETIME 
END
GO

IF COL_LENGTH('state_rec_requirement_detail', 'assignment_type_id') IS NULL
BEGIN
    ALTER TABLE state_rec_requirement_detail ADD assignment_type_id INT 
END
GO

IF COL_LENGTH('state_rec_requirement_detail', 'state_rec_requirement_data_id') IS NULL
BEGIN
	ALTER TABLE state_rec_requirement_detail ADD state_rec_requirement_data_id INT 
	ALTER TABLE state_rec_requirement_detail ADD CONSTRAINT FK_state_rec_requirement_detail FOREIGN KEY (state_rec_requirement_data_id) REFERENCES state_rec_requirement_data(state_rec_requirement_data_id);
END
GO  