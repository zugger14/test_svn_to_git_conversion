IF COL_LENGTH(N'[dbo].[report]', N'is_powerbi') IS NULL
BEGIN
    ALTER TABLE [dbo].[report]
    ADD is_powerbi bit NULL DEFAULT 0
    PRINT 'Column ''is_powerbi'' added on table ''[dbo].[report]''.'
END
ELSE
    PRINT 'Column ''is_powerbi'' on table ''[dbo].[report]'' already exists.'
GO