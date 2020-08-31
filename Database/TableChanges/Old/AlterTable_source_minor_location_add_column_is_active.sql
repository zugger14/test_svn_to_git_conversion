IF COL_LENGTH('source_minor_location', 'is_active') IS NULL
BEGIN
    ALTER TABLE source_minor_location ADD is_active CHAR(1)
END
GO
