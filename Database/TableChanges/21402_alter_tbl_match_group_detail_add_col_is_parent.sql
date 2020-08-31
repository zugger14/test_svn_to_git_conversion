IF COL_LENGTH('match_group_detail', 'is_parent') IS NULL
BEGIN
    ALTER TABLE match_group_detail ADD is_parent CHAR(1) COLLATE DATABASE_DEFAULT
END

GO

