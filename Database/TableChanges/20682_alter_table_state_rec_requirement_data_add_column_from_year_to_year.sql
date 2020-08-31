IF COL_LENGTH('state_rec_requirement_data', 'from_year') IS NULL
BEGIN 
    ALTER TABLE state_rec_requirement_data
	ADD from_year INT NULL
END
GO

IF COL_LENGTH('state_rec_requirement_data', 'to_year') IS NULL
BEGIN 
    ALTER TABLE state_rec_requirement_data
	ADD to_year INT NULL
END
GO


