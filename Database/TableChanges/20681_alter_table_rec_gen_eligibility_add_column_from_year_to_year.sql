IF COL_LENGTH('rec_gen_eligibility', 'from_year') IS NULL
BEGIN 
    ALTER TABLE rec_gen_eligibility
	ADD from_year INT NULL
END
GO

IF COL_LENGTH('rec_gen_eligibility', 'to_year') IS NULL
BEGIN 
    ALTER TABLE rec_gen_eligibility
	ADD to_year INT NULL
END
GO


