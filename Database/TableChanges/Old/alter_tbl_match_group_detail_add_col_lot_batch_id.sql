IF COL_LENGTH('match_group_detail', 'lot') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD lot VARCHAR(1000)
END
GO

IF COL_LENGTH('match_group_detail', 'batch_id') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD batch_id VARCHAR(1000)
END
GO

IF COL_LENGTH('match_group_detail', 'inco_terms') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD inco_terms INT
END
GO

IF COL_LENGTH('match_group_detail', 'crop_year') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD crop_year INT
END
GO

