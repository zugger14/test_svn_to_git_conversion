IF COL_LENGTH('rec_gen_eligibility', 'sub_tier_value_id') IS NULL
BEGIN
    ALTER TABLE rec_gen_eligibility ADD sub_tier_value_id INT NULL
END
GO

IF COL_LENGTH('rec_generator', 'sub_tier_value_id') IS NULL
BEGIN
    ALTER TABLE rec_generator ADD sub_tier_value_id INT NULL
END
GO
 
