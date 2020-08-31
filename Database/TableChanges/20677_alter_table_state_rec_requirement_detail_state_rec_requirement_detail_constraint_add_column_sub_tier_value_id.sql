IF COL_LENGTH('state_rec_requirement_detail', 'sub_tier_value_id') IS NULL
BEGIN
    ALTER TABLE state_rec_requirement_detail ADD sub_tier_value_id INT NULL
END
GO

IF COL_LENGTH('state_rec_requirement_detail_constraint', 'sub_tier_value_id') IS NULL
BEGIN
    ALTER TABLE state_rec_requirement_detail_constraint ADD sub_tier_value_id INT NULL
END
GO





