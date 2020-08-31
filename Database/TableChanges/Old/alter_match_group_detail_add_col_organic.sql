IF COL_LENGTH('match_group_detail', 'organic') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD organic CHAR(1)
END
GO

