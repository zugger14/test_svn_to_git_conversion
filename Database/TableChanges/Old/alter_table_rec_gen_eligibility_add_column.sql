IF COL_LENGTH('rec_gen_eligibility', 'technology_sub_type') IS NULL
BEGIN
    ALTER TABLE rec_gen_eligibility ADD technology_sub_type VARCHAR(100) NULL
END
GO

IF COL_LENGTH('rec_gen_eligibility', 'assignment_type') IS NULL
BEGIN
    ALTER TABLE rec_gen_eligibility ADD assignment_type VARCHAR(50) NULL
END
GO

IF COL_LENGTH('rec_gen_eligibility', 'from_month') IS NULL
BEGIN
    ALTER TABLE rec_gen_eligibility ADD from_month DATETIME NULL
END
GO

IF COL_LENGTH('rec_gen_eligibility', 'to_month') IS NULL
BEGIN
    ALTER TABLE rec_gen_eligibility ADD to_month DATETIME NULL
END
GO