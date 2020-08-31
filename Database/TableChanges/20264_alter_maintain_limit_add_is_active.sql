IF COL_LENGTH('maintain_limit', 'is_active') IS NULL
BEGIN
    ALTER TABLE maintain_limit ADD [is_active] CHAR(2)
END
GO
