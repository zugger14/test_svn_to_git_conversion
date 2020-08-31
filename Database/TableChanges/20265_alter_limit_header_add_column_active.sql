IF COL_LENGTH('limit_header', 'active') IS NULL
BEGIN
    ALTER TABLE limit_header ADD [active] CHAR(2)
END
GO
