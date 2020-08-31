IF COL_LENGTH(N'[dbo].[maintain_field_template]', N'is_mobile') IS NULL
BEGIN
    ALTER TABLE [dbo].[maintain_field_template]
    ADD is_mobile NCHAR(1) NOT NULL DEFAULT 'n'
    PRINT 'Column ''is_mobile'' added on table ''[dbo].[maintain_field_template]''.'
END
ELSE
    PRINT 'Column ''is_mobile'' on table ''[dbo].[maintain_field_template]'' already exists.'
GO