IF COL_LENGTH('pivot_report_view', 'is_public') IS NULL
BEGIN
    ALTER TABLE pivot_report_view ADD is_public BIT DEFAULT 0
END
GO

UPDATE pivot_report_view
SET is_public = 0
WHERE is_public IS NULL
GO
